# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :set_current_user, except: [:new, :create, :edit, :update]

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
  end

  def edit_profile
  end

  def validate_bestrip_id
    update_without_password_params[:avatar] = @user.avatar if @user.avatar
    @user.assign_attributes(update_without_password_params)
    @user.valid?
  end

  def update_without_password
    @user.assign_attributes(update_without_password_params)
    if @user.save(context: :without_password)
      flash[:notice] =
        (update_without_password_params.key?(:email) ? "メールアドレス" : "プロフィール") + "を変更しました。"
      redirect_to root_url
    else
      render update_without_password_params.key?(:email) ? :edit_email : :edit_profile
    end
  end

  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  def set_current_user
    @user = User.find(current_user.id)
  end

  def update_without_password_params
    params[:user][:bestrip_id] = nil if params[:user][:bestrip_id] == ""
    params.require(:user).permit(:name, :bestrip_id, :email, :avatar, :avatar_cache, :introduction)
  end
end
