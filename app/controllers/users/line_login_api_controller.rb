class Users::LineLoginApiController < ApplicationController
  def login
    invitation_code = params[:invitation_code]
    session[:state] = SecureRandom.urlsafe_base64
    line_login_api_callback_url = "https://f400-125-15-187-39.ngrok-free.app/line_login_api/callback"

    base_authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
    response_type = 'code'
    client_id = ENV['LINE_KEY']
    redirect_uri = CGI.escape(line_login_api_callback_url)
    redirect_uri += "?invitation_code=#{invitation_code}" if invitation_code
    state = session[:state]
    scope = 'profile%20openid%20email'
    authorization_url =
      "#{base_authorization_url}?response_type=#{response_type}&client_id=#{client_id}" +
      "&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    if params[:state] != session[:state]
      redirect_to root_path, notice: '不正なアクセスです。'
      return
    end

    @invitation_code = params[:invitation_code]

    p "HERE"
    line_user_profile = get_line_user_profile(params[:code], @invitation_code)

    if line_user_profile[:email].blank?
      existing_user = User.find_by(line_user_id: line_user_profile[:sub])
      if existing_user
        add_user_to_pending_invitation(existing_user)
        sign_in existing_user
        after_sign_in_path
      else
        flash[:notice] =
          "LINEアカウントにメールアドレスの登録が無いため、LINEでのログインはご利用いただけません。" +
          "メールアドレスでの登録をお願いします。"
        redirect_to new_user_session_path(invitation_code: @invitation_code)
      end
      return
    end

    existing_user = User.find_by(email: line_user_profile[:email])
    if existing_user
      if existing_user.line_user_id.blank?
        existing_user.update_attribute(:line_user_id, line_user_profile[:sub])
      end
      add_user_to_pending_invitation(existing_user)
      sign_in existing_user
      after_sign_in_path
      return
    end

    random_pass = SecureRandom.base36
    new_user = User.new(
      name: line_user_profile[:name],
      email: line_user_profile[:email],
      line_user_id: line_user_profile[:sub],
      password: random_pass,
      password_confirmation: random_pass,
    )
    new_user.setup_attach_avatar(line_user_profile[:picture]) if line_user_profile[:picture].present?

    if new_user.save
      add_user_to_pending_invitation(new_user)
      sign_in new_user
      after_sign_in_path
    else
      flash[:notice] = 'ログインに失敗しました。'
      redirect_to new_user_session_path(invitation_code: @invitation_code)
    end
  end

  private

  def get_line_user_profile(code, invitation_code)
    line_user_id_token = get_line_user_id_token(code, invitation_code)
    if line_user_id_token.present?
      url = 'https://api.line.me/oauth2/v2.1/verify'
      options = {
        body: {
          id_token: line_user_id_token,
          client_id: ENV['LINE_KEY'],
        },
      }
      response = Typhoeus::Request.post(url, options)
      response.code == 200 ? JSON.parse(response.body, symbolize_names: true) : nil
    else
      nil
    end
  end

  def get_line_user_id_token(code, invitation_code)
    url = 'https://api.line.me/oauth2/v2.1/token'
    redirect_uri = line_login_api_callback_url
    redirect_uri += "?invitation_code=#{invitation_code}" if invitation_code

    options = {
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
      },
      body: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri,
        client_id: ENV['LINE_KEY'],
        client_secret: ENV['LINE_SECRET'],
      },
    }
    response = Typhoeus::Request.post(url, options)
    response.code == 200 ? JSON.parse(response.body)['id_token'] : nil
  end

  def add_user_to_pending_invitation(user)
    if @invitation_code.present?
      @pending_invitation = PendingInvitation.find_by(invitation_code: @invitation_code)
      @pending_invitation.update(user_id: user.id)
    end
  end

  def after_sign_in_path
    flash[:notice] = "ログインしました。"
    redirect_to itineraries_path(invited_itinerary_id: @pending_invitation&.itinerary&.id)
  end
end
