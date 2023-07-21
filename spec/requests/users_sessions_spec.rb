require 'rails_helper'

RSpec.describe "UsersSessions", type: :request do
  let(:user) { create(:user) }

  describe "GET #new" do
    it "ログイン画面の表示に成功すること" do
      get new_user_session_path
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    it "ログインに成功すること" do
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      expect(response).to redirect_to root_path
    end

    it "ログインに失敗すること" do
      post user_session_path, params: { user: { email: "", password: "" } }
      expect(response).to have_http_status 422
    end
  end

  describe "DELETE #destroy" do
    it "ログアウトに成功すること" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to root_path # 修正する
    end
  end
end
