require 'rails_helper'

RSpec.describe "UsersRegistrations", type: :request do
  let(:user) { create(:user) }

  describe "GET /new" do
    it "正常にレスポンスを返すこと" do
      get new_user_registration_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /account" do
    before do
      sign_in user
      get users_account_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end

    it "メールアドレスを取得すること" do
      expect(response.body).to include user.email
    end
  end

  describe "PUT /update" do
    before do
      sign_in user
      get users_account_path
    end

    it "メールアドレスを変更できること" do
      put user_registration_path, params: { user: { email: "new_email@example.com", current_password: user.password } }
      expect(user.reload.email).to eq "new_email@example.com"
    end

    it "パスワードを変更できること" do
      put user_registration_path, params: { user: {password: "newpassword", password_confirmation: "newpassword", current_password: user.password } }
      sign_out user
      post user_session_path, params: { user: { email: user.email, password: "newpassword" } }
      expect(response).to redirect_to root_path
    end
  end
end
