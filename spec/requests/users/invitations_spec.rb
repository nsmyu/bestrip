require 'rails_helper'

RSpec.describe "Users::Invitations", type: :request, focus: true do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_user_invitation_path(id: itinerary.id)
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        invitation_params = { user: { name: "newly_invited", email: other_user.email} }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params
        expect(response).to redirect_to itinerary_path(itinerary.id)
        expect(other_user.reload.invited_to_itineraries).to include itinerary
      end
    end

    context "無効な値の場合" do
      it "メールアドレスが空欄の場合、失敗すること" do
        invitation_params = { user: { name: "newly_invited", email: "" } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "メールアドレスを入力してください"
      end

      it "メールアドレスが不正な形式の場合、失敗すること" do
        invitation_params = { user: { name: "newly_invited", email: "invalid_email_address" } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "メールアドレスを正しく入力してください"
      end

      it "招待しようとしたユーザーが既にメンバーに含まれている場合、失敗すること" do
        itinerary.members << other_user
        invitation_params = { user: { name: "newly_invited", email: other_user.email } }
        post user_invitation_path(itinerary_id: itinerary.id), params: invitation_params,
                                                               headers: turbo_stream
        expect(response.body).to include "#{other_user.name}さんはすでにメンバーに含まれています"
      end
    end
  end

  describe "GET #edit" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe "PATCH #update" do
    pending "add some examples (or delete) #{__FILE__}"
  end
end
