require 'rails_helper'

RSpec.describe "UsersSessions", type: :request do
  let(:user) { create(:user) }

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_user_session_path
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    it "有効な値の場合、ログインに成功すること" do
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      expect(response).to redirect_to root_path
    end

    it "メールアドレスが間違っている場合、ログインに失敗すること" do
      post user_session_path,
        params: { user: { email: "wrong@example.com", password: user.password } }
      expect(response.body).to include "メールアドレスまたはパスワードが違います。"
    end

    it "パスワードが間違っている場合、ログインに失敗すること" do
      post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
      expect(response.body).to include "メールアドレスまたはパスワードが違います。"
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
