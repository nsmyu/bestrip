class Users::LineLoginApiController < ApplicationController
  def login
    session[:state] = SecureRandom.urlsafe_base64
    line_login_api_callback_url = "https://8031-125-15-187-39.ngrok-free.app/line_login_api/callback"

    base_authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
    response_type = 'code'
    client_id = ENV['LINE_KEY']
    redirect_uri = CGI.escape(line_login_api_callback_url)
    state = session[:state]
    scope = 'profile%20openid%20email'
    authorization_url = "#{base_authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    if params[:state] == session[:state]
      line_user_profile = get_line_user_profile(params[:code])
      user = User.find_or_initialize_by(line_user_id: line_user_profile[:sub])

      if user.id
        sign_in user
        redirect_to itineraries_path, notice: 'ログインしました。'
        return
      end

      random_pass = SecureRandom.base36
      user.name = line_user_profile[:name]
      user.password = random_pass
      user.password_confirmation = random_pass
      user.email = line_user_profile[:email] if line_user_profile[:email].present?
      user.setup_attach_avatar(line_user_profile[:picture]) if line_user_profile[:picture].present?

      if user.save
        sign_in user
        redirect_to itineraries_path, notice: 'ログインしました。'
      else
        redirect_to root_path, notice: 'ログインに失敗しました。'
      end
    else
      redirect_to root_path, notice: '不正なアクセスです。'
    end
  end

  private

  def get_line_user_profile(code)
    line_user_id_token = get_line_user_id_token(code)
    if line_user_id_token.present?
      url = 'https://api.line.me/oauth2/v2.1/verify'
      options = {
        body: {
          id_token: line_user_id_token,
          client_id: ENV['LINE_KEY'],
        }
      }
      response = Typhoeus::Request.post(url, options)
      if response.code == 200
        JSON.parse(response.body, symbolize_names: true)
      else
        nil
      end
    else
      nil
    end
  end

  def get_line_user_id_token(code)
    url = 'https://api.line.me/oauth2/v2.1/token'
    redirect_uri = line_login_api_callback_url

    options = {
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri,
        client_id: ENV['LINE_KEY'],
        client_secret: ENV['LINE_SECRET']
      }
    }
    response = Typhoeus::Request.post(url, options)

    if response.code == 200
      JSON.parse(response.body)['id_token']
    else
      nil
    end
  end
end
