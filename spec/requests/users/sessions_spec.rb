require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_user_session_path
      expect(response).to have_http_status 200
    end

    it "既存ユーザーが招待メールからアクセスした場合、正常にレスポンスを返すこと" do
      itinerary = create(:itinerary)
      get new_user_session_path(id: user.id, itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
      expect(response.body).to include user.email
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "ログインに成功すること" do
        user_params = { email: user.email, password: user.password }
        post user_session_path, params: { user: user_params }
        expect(response).to redirect_to itineraries_path
      end
    end

    context "無効な値の場合" do
      it "メールアドレスが間違っている場合、ログインに失敗すること" do
        user_params = { email: "wrong@example.com", password: user.password }
        post user_session_path, params: { user: user_params }, headers: turbo_stream
        expect(response.body).to include "メールアドレスまたはパスワードが違います。"
      end

      it "パスワードが間違っている場合、ログインに失敗すること" do
        user_params = { email: user.email, password: "wrongpassword" }
        post user_session_path, params: { user: user_params }, headers: turbo_stream
        expect(response.body).to include "メールアドレスまたはパスワードが違います。"
      end
    end
  end

  describe "DELETE #destroy" do
    it "ログアウトに成功すること" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to root_path
    end
  end
end
