require 'rails_helper'

RSpec.describe "UsersRegistrations", type: :request do
  let(:user) { create(:user) }

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_user_registration_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET #edit" do
    before do
      sign_in user
      get users_edit_password_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end
  end

  describe "PATCH #update" do
    before do
      sign_in user
    end

    it "パスワードを変更できること" do
      user_params = {
        user: {
          current_password: user.password,
          password: "newpassword",
          password_confirmation: "newpassword",
        },
      }
      patch user_registration_path, params: user_params
      sign_out user
      post user_session_path, params: { user: { email: user.email, password: "newpassword" } }
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq "ログインしました。"
    end
  end

  describe "GET #edit_email" do
    before do
      sign_in user
      get users_edit_email_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end

    it "メールアドレスを取得すること" do
      expect(response.body).to include user.email
    end
  end

  describe "GET #edit_profile" do
    before do
      sign_in user
      get users_edit_profile_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end

    it "ニックネームを取得すること" do
      expect(response.body).to include "Conan"
    end
  end

  describe "PATCH #update_without_password" do
    before do
      sign_in user
    end

    it "メールアドレスを変更できること" do
      patch users_update_without_password_path, params: { user: { email: "new_email@example.com" } }
      expect(user.reload.email).to eq "new_email@example.com"
    end

    it "ニックネームを変更できること" do
      patch users_update_without_password_path, params: { user: { name: "Shinichi" } }
      expect(user.reload.name).to eq "Shinichi"
    end

    it "自己紹介を変更できること" do
      patch users_update_without_password_path, params: { user: { introduction: "真実はいつもひとつ" } }
      expect(user.reload.introduction).to eq "真実はいつもひとつ"
    end
  end
end
