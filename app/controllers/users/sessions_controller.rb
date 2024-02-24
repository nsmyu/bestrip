class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: :create

  def new
    session[:previous_url] = request.referer

    if params[:itinerary_id]
      set_itinerary
      sign_in_params = ActiveSupport::HashWithIndifferentAccess
        .new(email: User.find(params[:id]).email)
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

  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to itineraries_path, notice: "ゲストユーザーとしてログインしました。"
  end

  protected

  def after_sign_in_path_for(resource_or_scope)
    if params[:user] && params[:user][:invited_itinerary_id]
      itineraries_path(invited_itinerary_id: params[:user][:invited_itinerary_id])
    elsif session[:previous_url] && URI(session[:previous_url].to_s).path.start_with?("/posts")
      session[:previous_url]
    else
      itineraries_path
    end
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
