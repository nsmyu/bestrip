class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: :create

  def new
    session[:previous_url] = request.referer
    super
  end

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
    end
  end

  def edit_email
  end

  def edit_profile
  end

  def validate_bestrip_id
    current_user.assign_attributes(update_without_password_params)
    current_user.valid?
    @blank_error = "お好みのIDを入力してください" if current_user.bestrip_id.blank?
  end

  def update
    return if block_guest_user

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      flash[:notice] = "パスワードを変更しました。"
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      redirect_to :edit_user_registration
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def update_without_password
    return if block_guest_user

    current_user.assign_attributes(update_without_password_params)
    if current_user.save(context: :without_password)
      if update_without_password_params.key?(:email)
        redirect_to :users_edit_email, notice: "メールアドレスを変更しました。"
      else
        redirect_to :users_edit_profile, notice: "プロフィールを変更しました。"
      end
    else
      render update_without_password_params.key?(:email) ? :edit_email : :edit_profile
    end
  end

  private

  def after_sign_up_path_for(resource)
    if session[:previous_url] && URI(session[:previous_url].to_s).path.start_with?("/posts")
      session[:previous_url]
    else
      itineraries_path
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def update_without_password_params
    params.require(:user).permit(:name, :bestrip_id, :email, :avatar, :introduction)
  end

  def block_guest_user
    if current_user.guest? && !params[:user][:name]
      redirect_to request.referer, notice: "ゲストユーザーの方は変更できません。"
    end
  end
end
