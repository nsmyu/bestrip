require 'rails_helper'

RSpec.describe "Users::Invitations", type: :request do
  let(:user) { create(:user) }
  let(:invitee) { build(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }
  let(:invitation_token) { Devise.token_generator.generate(User, :invitation_token) }
  # invitation_token[0]にトークン, invitation_token[1]にそのダイジェスト値が格納される

  describe "GET #new" do
    before do
      sign_in user
    end

    it "正常にレスポンスを返すこと" do
      get new_user_invitation_path(id: itinerary.id)
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    before do
      sign_in user
    end

    context "有効な値の場合" do
      it "アカウント未登録ユーザーへのメール送信に成功すること" do
        invitation_params = { user: { name: invitee.name, email: invitee.email } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params
        expect(response).to redirect_to itinerary_path(itinerary.id)
        expect(itinerary.reload.invitees).to include User.last
      end

      it "既存ユーザーへの招待メール送信に成功すること" do
        invitee.save
        invitation_params = { user: { email: invitee.email } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params
        expect(response).to redirect_to itinerary_path(itinerary.id)
        expect(itinerary.reload.invitees).to include invitee
      end
    end

    context "無効な値の場合" do
      it "メールアドレスが空欄の場合、失敗すること" do
        invitation_params = { user: { name: invitee.name, email: "" } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "メールアドレスを入力してください"
      end

      it "メールアドレスが不正な形式の場合、失敗すること" do
        invitation_params = { user: { name: invitee.name, email: "invalid_email_address" } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "メールアドレスを正しく入力してください"
      end

      it "招待しようとしたユーザーが既にメンバーに含まれている場合、失敗すること" do
        invitee.save
        itinerary.members << invitee
        invitation_params = { user: { email: invitee.email } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "#{invitee.name}さんはすでにメンバーに含まれています"
      end
    end
  end

  describe "GET #edit" do
    it "正常にレスポンスを返すこと" do
      invitee.save
      invitee.update(invitation_token: invitation_token[1])
      accept_params = { invitation_token: invitation_token[0], itinerary_id: itinerary.id }
      get accept_user_invitation_path, params: accept_params
      expect(response).to have_http_status 200
    end
  end

  describe "PATCH #update" do
    before do
      invitee.save
      invitee.update(invitation_token: invitation_token[1])
      @user_params = {
        name: invitee.name,
        password: invitee.password,
        password_confirmation: invitee.password_confirmation,
        invitation_token: invitation_token[0],
      }
    end

    context "有効な値の場合" do
      it "成功すること" do
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response).to redirect_to itineraries_path(invited_itinerary_id: itinerary.id)
        expect(invitee.pending_invitations).not_to include itinerary
      end
    end

    context "無効な値の場合" do
      it "ニックネームが空欄の場合、失敗すること" do
        @user_params[:name] = ""
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "ニックネームを入力してください"
      end

      it "ニックネームが21文字以上の場合、失敗すること" do
        @user_params[:name] = "a" * 21
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "ニックネームは20文字以内で入力してください"
      end

      it "パスワードが空欄の場合、失敗すること" do
        @user_params[:password] = ""
        @user_params[:password_confirmation] = ""
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "パスワードを入力してください"
      end

      it "パスワードが5文字以下の場合、失敗すること" do
        @user_params[:password] = "a" * 5
        @user_params[:password_confirmation] = "a" * 5
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "パスワードは6文字以上で入力してください"
      end

      it "パスワードが129文字以上の場合、失敗すること" do
        @user_params[:password] = "a" * 129
        @user_params[:password_confirmation] = "a" * 129
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "パスワードは128文字以内で入力してください"
      end

      it "パスワードに半角英数字以外が含まれている場合、失敗すること" do
        @user_params[:password] = "invalid-password"
        @user_params[:password_confirmation] = "invalid-password"
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "パスワードは半角英数字で入力してください"
      end

      it "確認用パスワードが一致しない場合、失敗すること" do
        @user_params[:password_confirmation] = "wrongpassoword"
        patch user_invitation_path, params: { user: @user_params, itinerary_id: itinerary.id }
        expect(response.body).to include "パスワード（確認用）とパスワードの入力が一致しません"
      end
    end
  end
end
