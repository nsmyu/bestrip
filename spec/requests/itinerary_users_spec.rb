require 'rails_helper'

RSpec.describe "ItineraryUsers", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user_1) { create(:user, bestrip_id: "other_user_1_id") }
  let(:other_user_2) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "GET #new" do
    it "ログインユーザーがプランのメンバーである場合、 正常にレスポンスを返すこと" do
      get new_itinerary_user_path(itinerary.id)
      expect(response).to have_http_status 200
    end

    it "ログインユーザーがプランのメンバーではない場合、indexにリダイレクトされること" do
      sign_in other_user_1
      get new_itinerary_user_path(itinerary.id)
      expect(response).to redirect_to itineraries_path
    end
  end

  describe "GET #search_user" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "検索したBesTrip IDのユーザーを返すこと" do
        user_search_params = { bestrip_id: other_user_1.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include other_user_1.name
      end

      it "検索したBesTrip IDのユーザーが存在しない場合、メッセージを返すこと" do
        user_search_params = { bestrip_id: "no_user_id", id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include "ユーザーが見つかりませんでした"
      end

      it "検索したBesTrip IDのユーザーが既にメンバーに含まれている場合、メッセージを返すこと" do
        itinerary.members << other_user_1
        user_search_params = { bestrip_id: other_user_1.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include other_user_1.name
        expect(response.body).to include "すでにメンバーに追加されています"
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "indexにリダイレクトされること" do
        sign_in other_user_1
        user_search_params = { bestrip_id: user.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "POST #create" do
    it "ログインユーザーがプランのメンバーである場合、成功すること" do
      add_member_params = { user_id: other_user_1.id, id: itinerary.id }
      post itinerary_users_path(itinerary.id), params: add_member_params
      expect(response).to redirect_to itinerary_path(itinerary.id)
      expect(itinerary.reload.members).to include other_user_1
    end

    it "ログインユーザーがプランのメンバーではない場合、失敗すること" do
      sign_in other_user_1
      add_member_params = { user_id: other_user_2.id, id: itinerary.id }
      post itinerary_users_path(itinerary.id), params: add_member_params
      expect(itinerary.reload.members).not_to include other_user_2
    end
  end

  describe "DELETE #destroy" do
    before do
      itinerary.members << other_user_1 << other_user_2
    end

    it "ログインユーザーがプラン作成者の場合、成功すること" do
      remove_member_params = { user_id: other_user_1.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(response).to redirect_to itinerary_path(itinerary.id)
      expect(itinerary.reload.members).not_to include other_user_1
    end

    it "ログインユーザーがプラン作成者ではない場合、失敗すること" do
      sign_in other_user_1
      remove_member_params = { user_id: other_user_2.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(itinerary.reload.members).to include other_user_2
    end

    it "作成者をメンバーから削除することはできないこと" do
      remove_member_params = { user_id: user.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(itinerary.reload.members).to include user
    end
  end
end
