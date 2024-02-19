class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: :create

  def create
    user = User.find_by(email: params[:user][:email])
    if user.invited_to_sign_up?
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

  def after_sign_in_path_for(resource)
    itineraries_path
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
