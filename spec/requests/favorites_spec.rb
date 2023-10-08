require 'rails_helper'

RSpec.describe "Favorites", type: :request, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:favorite) { create(:favorite, :opera_house, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_favorites_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end

    it "行きたい場所リストに登録されているスポットを全て取得すること", vcr: "google_api_response" do
      favorite
      create(:favorite, :queen_victoria_building, itinerary_id: itinerary.id)
      get itinerary_favorites_path(itinerary_id: itinerary.id)
      expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
    end

    it "他の旅のプランのスケジュールを取得しないこと", vcr: "google_api_response" do
      other_itinerary = create(:itinerary, owner: user)
      create(:favorite, :opera_house, itinerary_id: other_itinerary.id)
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response.body).not_to include "シドニー・オペラハウス"
    end

    it "place_idが無効な（変更されている）場合、エラーメッセージを取得すること" do
      create(:favorite, place_id: "invalid_place_id", itinerary_id: itinerary.id)
      get itinerary_favorites_path(itinerary_id: itinerary.id)
      expect(response.body).to include "スポット情報を取得できませんでした"
    end
  end

  describe "GET #new" do
    context "選択したスポットが行きたい場所リストへ登録可能な場合" do
      it "正常にレスポンスを返すこと", vcr: "google_api_response" do
        get new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect(response).to have_http_status 200
      end

      it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
        get new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect(response.body).to include "シドニー・オペラハウス"
        expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end

    context "選択したスポットが行きたい場所リストへ登録不可能な場合" do
      it "既に行きたい場所リストに登録済みの場合、メッセージを取得すること" do
        favorite
        get new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect(response.body).to include "行きたい場所リストに追加済み"
      end

      it "行きたい場所リストに上限の300件が登録されている場合、メッセージを取得すること" do
        create_list(:favorite, 300, itinerary: itinerary)
        new_favorite = build(:favorite, :opera_house)
        get new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: new_favorite.place_id)
        expect(response.body).to include "ひとつの旅のプランにつき、行きたい場所リストへの登録は300件までです。"
      end
    end
  end

  describe "POST #create" do
    it "成功すること" do
      favorite_params = attributes_for(:favorite)
      post itinerary_favorites_path(itinerary_id: itinerary.id),
        params: { favorite: favorite_params }
      expect(response.body).to include '<turbo-frame id="favorite">'
      expect(response.body).to include '行きたい場所リストに追加済み'
    end
  end

  describe "GET #show" do
    it "正常にレスポンスを返すこと", vcr: "google_api_response" do
      get itinerary_favorite_path(itinerary_id: itinerary.id, id: favorite.id)
      expect(response).to have_http_status 200
    end

    it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
      get itinerary_favorite_path(itinerary_id: itinerary.id, id: favorite.id)
      expect(response.body).to include "シドニー・オペラハウス"
      expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete itinerary_favorite_path(itinerary_id: itinerary.id, id: favorite.id)
      expect(response).to redirect_to itinerary_favorites_path
    end
  end
end
