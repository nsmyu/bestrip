require 'rails_helper'

RSpec.describe "ItineraryUsers", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user1) { create(:user, bestrip_id: "other_user1_id") }
  let(:other_user2) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_itinerary_user_path(itinerary.id)
      expect(response).to have_http_status 200
    end
  end

  describe "GET #search_user" do
    it "検索したBesTrip IDのユーザーを返すこと" do
      user_search_params = { bestrip_id: other_user1.bestrip_id, id: itinerary.id }
      get search_user_itinerary_path(itinerary.id), params: user_search_params
      expect(response.body).to include other_user1.name
    end

    it "検索したBesTrip IDのユーザーが存在しない場合、メッセージを返すこと" do
      user_search_params = { bestrip_id: "no_user_id", id: itinerary.id }
      get search_user_itinerary_path(itinerary.id), params: user_search_params
      expect(response.body).to include "ユーザーが見つかりませんでした"
    end

    it "検索したBesTrip IDのユーザーが既にメンバーに含まれている場合、メッセージを返すこと" do
      itinerary.members << other_user1
      user_search_params = { bestrip_id: other_user1.bestrip_id, id: itinerary.id }
      get search_user_itinerary_path(itinerary.id), params: user_search_params
      expect(response.body).to include other_user1.name
      expect(response.body).to include "すでにメンバーに追加されています"
    end
  end

  describe "POST #create" do
    it "成功すること" do
      add_member_params = { user_id: other_user1.id, id: itinerary.id }
      post itinerary_users_path(itinerary.id), params: add_member_params
      expect(response).to redirect_to itinerary_path(itinerary.id)
      expect(itinerary.reload.members).to include other_user1
    end
  end

  describe "DELETE #remove_member" do
    before do
      itinerary.members << other_user1 << other_user2
    end

    it "成功すること" do
      remove_member_params = { user_id: other_user1.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(response).to redirect_to itinerary_path(itinerary.id)
      expect(itinerary.reload.members).not_to include other_user1
    end

    it "作成者以外はメンバーを削除できないこと" do
      sign_out user
      sign_in other_user1
      remove_member_params = { user_id: other_user2.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(itinerary.reload.members).to include other_user2
    end

    it "作成者をメンバーから削除することはできないこと" do
      remove_member_params = { user_id: user.id, id: itinerary.id }
      delete itinerary_user_path(itinerary.id), params: remove_member_params
      expect(itinerary.reload.members).to include user
    end
  end
end
