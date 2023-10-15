require 'rails_helper'

RSpec.describe "UsersRegistrations", type: :request do
  let(:user) { create(:user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_user_registration_path
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    it "正常な値の場合、ユーザー登録に成功すること" do
      user_params = attributes_for(:user)
      post user_registration_path, params: { user: user_params }
      expect(response).to redirect_to root_path
    end

    it "無効な値の場合、ユーザー登録に失敗すること" do
      user_params = attributes_for(:user, name: "")
      post user_registration_path, params: { user: user_params }
      expect(response.body).to include "ニックネームを入力してください"
    end
  end

  describe "GET #edit" do
    it "正常にレスポンスを返すこと" do
      sign_in user
      get users_edit_password_path
      expect(response).to have_http_status 200
    end
  end

  describe "PATCH #update" do
    it "パスワードを変更できること" do
      sign_in user
      user_params = {
        user: {
          current_password: user.password,
          password: "newpassword",
          password_confirmation: "newpassword",
        },
      }
      patch user_registration_path, params: user_params
      expect(response).to redirect_to users_edit_password_path
    end
  end

  describe "GET #edit_email" do
    before do
      sign_in user
      get users_edit_email_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
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
      expect(response).to have_http_status 200
    end

    it "ニックネームを取得すること" do
      expect(response.body).to include user.name
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
      patch users_update_without_password_path, params: { user: { name: "New nickname" } }
      expect(user.reload.name).to eq "New nickname"
    end

    it "自己紹介を変更できること" do
      patch users_update_without_password_path,
        params: { user: { introduction: "I love traveling to different countries." } }
      expect(user.reload.introduction).to eq "I love traveling to different countries."
    end
  end

  describe "PATCH #validate_bestrip_id" do
    before do
      sign_in user
    end

    it "IDが一意である場合、使用可能のメッセージを取得すること" do
      patch users_validate_bestrip_id_path, params: { user: { bestrip_id: "user_id" } },
                                            headers: turbo_stream
      expect(response.body).to include 'このIDはご使用いただけます'
    end

    it "IDが一意でない場合、エラーメッセージを取得すること" do
      create(:user, bestrip_id: "user_id")
      patch users_validate_bestrip_id_path, params: { user: { bestrip_id: "user_id" } },
                                            headers: turbo_stream
      expect(response.body).to include 'このIDは他の人が使用しています'
    end
  end

  describe "DELETE #destroy" do
    it "アカウントを削除できること" do
      delete user_registration_path(user.id)
      # expect(response).to redirect_to
    end
  end
end
