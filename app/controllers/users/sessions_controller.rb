class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: :create

  def new
    session[:previous_url] = request.referer

    invitation_token = params[:invitation_token]
    if invitation_token.present?
      digest = Devise.token_generator.digest(User, :invitation_token, invitation_token)
      user = User.find_by(invitation_token: digest)
      if user
        @invited_itinerary = Itinerary.find(params[:itinerary_id])
        sign_in_params = ActiveSupport::HashWithIndifferentAccess.new(email: user.email)
      end
    end

    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  def create
    user = User.find_by(email: params[:user][:email])
    if user&.invited_to_sign_up?
      user.update_columns(invitation_accepted_at: Time.current, invitation_token: nil)
    end
    super
  end

  def fail
  end

  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to itineraries_path, notice: "ゲストユーザーとしてログインしました。"
  end

  private

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end

  def after_sign_in_path_for(resource_or_scope)
    if params[:user].present? && params[:user][:invited_itinerary_id]
      itineraries_path(invited_itinerary_id: params[:user][:invited_itinerary_id])
    elsif session[:previous_url] && URI(session[:previous_url].to_s).path.start_with?("/posts")
      session[:previous_url]
    else
      itineraries_path
    end
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#fail", locale: I18n.locale }
  end
end
