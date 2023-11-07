class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: :create

  def new
    super
  end

  def create
    super
  end

  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to root_path, notice: "ゲストユーザーとしてログインしました。"
  end

  def destroy
    super
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
