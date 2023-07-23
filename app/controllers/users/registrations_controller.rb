# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def new
    super
  end

  def create
    super
  end

  def edit
    super
  end

  def update
    super
    flash[:notice] = "パスワードを変更しました。"
  end

  def edit_email
    @user = User.find(current_user.id)
  end

  def edit_profile
    @user = User.find(current_user.id)
  end

  def update_without_password
    @user = User.find(current_user.id)
    @user.assign_attributes(user_profile_params)
    if @user.save(context: :without_password)
      flash[:notice] = "メールアドレスを変更しました。"
      redirect_to root_path
    else
      render 'edit_email'
    end
  end

  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  end

  def configure_user_params
    devise_parameter_sanitizer.permit(:update_without_password, keys: [:name, :bestrip_id, :email, :avatar, :introduction])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  def user_email_params
    params.require(:user).permit(:email)
  end

  def user_profile_params
    params.require(:user).permit(:name, :introduction, :avatar)
  end
end
