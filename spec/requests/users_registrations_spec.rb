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
    context "有効な値の場合" do
      it "成功すること" do
        user_params = attributes_for(:user)
        post user_registration_path, params: { user: user_params }
        expect(response).to redirect_to itineraries_path
      end
    end

    context "無効な値の場合" do
      it "ニックネームが空欄の場合、失敗すること" do
        user_params = attributes_for(:user, name: "")
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "ニックネームを入力してください"
      end

      it "ニックネームが21文字以上の場合、失敗すること" do
        user_params = attributes_for(:user, name: "a" * 21)
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "ニックネームは20文字以内で入力してください"
      end

      it "メールアドレスが空欄の場合、失敗すること" do
        user_params = attributes_for(:user, email: "")
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "メールアドレスを入力してください"
      end

      it "メールアドレスが他のユーザーと重複している場合、失敗すること" do
        user
        user_params = attributes_for(:user, email: user.email)
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "このメールアドレスはすでに登録されています"
      end

      it "メールアドレスが不正な形式の場合、失敗すること" do
        user_params = attributes_for(:user, email: "invalid_email_address")
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "メールアドレスを正しく入力してください"
      end

      it "パスワードが5文字以下の場合、失敗すること" do
        user_params = attributes_for(:user, password: "a" * 5, password_confirmation: "a" * 5)
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "パスワードは6文字以上で入力してください"
      end

      it "パスワードが129文字以上の場合、失敗すること" do
        user_params = attributes_for(:user, password: "a" * 129, password_confirmation: "a" * 129)
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "パスワードは128文字以内で入力してください"
      end

      it "パスワードに半角英数字以外が含まれている場合、失敗すること" do
        user_params = attributes_for(:user, password: "invalid-password",
                                            password_confirmation: "invalid-password")
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "パスワードは半角英数字で入力してください"
      end

      it "確認用パスワードが一致しない場合、失敗すること" do
        user_params = attributes_for(:user, password_confirmation: "wrongpassword")
        post user_registration_path, params: { user: user_params }
        expect(response.body).to include "パスワード（確認用）とパスワードの入力が一致しません"
      end
    end
  end

  describe "GET #edit" do
    it "正常にレスポンスを返すこと" do
      sign_in user
      get edit_user_registration_path
      expect(response).to have_http_status 200
    end
  end

  describe "PATCH #update" do
    before do
      sign_in user
    end

    context "有効な値の場合" do
      it "成功すること" do
        user_params = attributes_for(:user, current_password: user.password,
                                            password: "newpassword",
                                            password_confirmation: "newpassword")
        patch user_registration_path, params: { user: user_params }
        expect(response).to redirect_to edit_user_registration_path
      end
    end

    context "無効な値の場合" do
      it "現在のパスワードが間違っている場合、失敗すること" do
        user_params = attributes_for(:user, current_password: "wrongpassword",
                                            password: "newpassword",
                                            password_confirmation: "newpassword")
        patch user_registration_path, params: { user: user_params }
        expect(response.body).to include "現在のパスワードが間違っています"
      end

      it "確認用パスワードが一致しない場合、失敗すること" do
        user_params = attributes_for(:user, current_password: user.password,
                                            password: "newpassword",
                                            password_confirmation: "passwordnew")
        patch user_registration_path, params: { user: user_params }
        expect(response.body).to include "パスワード（確認用）とパスワードの入力が一致しません"
      end
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

    it "ニックネーム、bestrip ID、自己紹介を取得すること" do
      expect(response.body).to include user.name
      expect(response.body).to include user.bestrip_id
      expect(response.body).to include user.introduction
    end
  end

  describe "PATCH #update_without_password" do
    before do
      sign_in user
    end

    context "有効な値の場合" do
      it "メールアドレスの変更に成功すること" do
        user_params = { email: "edited_email@example.com" }
        patch users_update_without_password_path, params: { user: user_params }
        expect(user.reload.email).to eq "edited_email@example.com"
        expect(response).to redirect_to users_edit_email_path
      end

      it "ニックネーム、BesTrip ID、自己紹介の変更に成功すること" do
        user_params = {
          name: "edited name",
          bestrip_id: "edited_id",
          introduction: "Edited introduction.",
        }
        patch users_update_without_password_path, params: { user: user_params }
        expect(user.reload.name).to eq "edited name"
        expect(user.reload.bestrip_id).to eq "edited_id"
        expect(user.reload.introduction).to eq "Edited introduction."
        expect(response).to redirect_to users_edit_profile_path
      end
    end

    context "無効な値の場合" do
      it "メールアドレスが他のユーザーと重複している場合、失敗すること" do
        other_user = create(:user, email: "other_user@example.com")
        user_params = attributes_for(:user, email: other_user.email)
        patch users_update_without_password_path, params: { user: user_params }
        expect(response.body).to include "このメールアドレスはすでに登録されています"
        expect(user.reload.email).to eq user.email
      end

      it "メールアドレスが不正な形式の場合、失敗すること" do
        user_params = { email: "invalid_email_address" }
        patch users_update_without_password_path, params: { user: user_params }
        expect(response.body).to include "メールアドレスを正しく入力してください"
        expect(user.reload.email).to eq user.email
      end

      it "ニックネームが空欄の場合、失敗すること" do
        user_params = { name: "" }
        patch users_update_without_password_path, params: { user: user_params }
        expect(response.body).to include "ニックネームを入力してください"
        expect(user.reload.name).to eq user.name
      end

      it "ニックネームが21文字以上の場合、失敗すること" do
        user_params = { name: "a" * 21 }
        patch users_update_without_password_path, params: { user: user_params }
        expect(response.body).to include "ニックネームは20文字以内で入力してください"
        expect(user.reload.name).to eq user.name
      end

      it "IDが一意でない場合、失敗すること" do
        create(:user, bestrip_id: "user_id")
        user_params = { bestrip_id: "user_id" }
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'このIDは他の人が使用しています'
        expect(user.reload.bestrip_id).to eq user.bestrip_id
      end
    end
  end

  describe "PATCH #validate_bestrip_id" do
    before do
      sign_in user
    end

    context "有効な値の場合" do
      it "IDがユーザー間で一意である場合、使用可能のメッセージを取得すること" do
        user_params = attributes_for(:user, bestrip_id: "user_id")
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'このIDは使用できます'
      end
    end

    context "無効な値の場合" do
      it "IDがユーザー間で一意でない場合、使用不可のメッセージを取得すること" do
        create(:user, bestrip_id: "user_id")
        user_params = attributes_for(:user, bestrip_id: "user_id")
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'このIDは他の人が使用しています'
      end

      it "IDが4文字以下の場合、エラーメッセージを取得すること" do
        user_params = attributes_for(:user, bestrip_id: "a" * 4)
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'IDは5文字以上で入力してください'
      end

      it "IDが21文字以上の場合、エラーメッセージを取得すること" do
        user_params = attributes_for(:user, bestrip_id: "a" * 21)
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'IDは20文字以内で入力してください'
      end

      it "IDに無効な文字が使用されている場合、エラーメッセージを取得すること" do
        user_params = attributes_for(:user, bestrip_id: "invalid-id")
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'IDは半角英数字とアンダーバー(_)で入力してください'
      end

      it "IDが空欄の場合、メッセージを取得すること" do
        user_params = attributes_for(:user, bestrip_id: "")
        patch users_validate_bestrip_id_path, params: { user: user_params },
                                              headers: turbo_stream
        expect(response.body).to include 'お好みのIDを入力してください'
      end
    end
  end
end
