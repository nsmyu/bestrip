require 'rails_helper'

RSpec.describe "Destinations", type: :request do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let!(:favorite) { create(:favorite, user: user) }
  let(:destination) { create(:destination, :opera_house, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_destinations_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end

    it "行きたい場所を全て取得すること", vcr: "google_api_response" do
      destination
      create(:destination, :queen_victoria_building, itinerary: itinerary)
      get itinerary_destinations_path(itinerary_id: itinerary.id)
      expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
    end

    it "他の旅のプランの行きたい場所を取得しないこと", vcr: "google_api_response" do
      other_itinerary = create(:itinerary, owner: user)
      create(:destination, :opera_house, itinerary: other_itinerary)
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response.body).not_to include "シドニー・オペラハウス"
    end

    it "place_idが無効な（変更されている）場合、エラーメッセージを取得すること" do
      create(:destination, place_id: "invalid_place_id", itinerary: itinerary)
      get itinerary_destinations_path(itinerary_id: itinerary.id)
      expect(response.body).to include "スポット情報を取得できませんでした"
    end
  end

  describe "GET #select_itinerary" do
    it "正常にレスポンスを返すこと" do
      get destinations_select_itinerary_itineraries_path(favorite_id: favorite.id)
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        destination_params = attributes_for(:destination)
        post itinerary_destinations_path(itinerary_id: itinerary.id),
          params: { destination: destination_params }
        expect(response.body).to include '行きたい場所に追加しました'
      end
    end

    context "無効な値の場合" do
      it "同じ旅のプランでplace_idが重複している場合、エラーメッセージを取得すること" do
        destination
        destination_params = attributes_for(:destination, place_id: destination.place_id)
        post itinerary_destinations_path(itinerary_id: destination.itinerary.id),
          params: { destination: destination_params }
        expect(response.body).to include "この旅のプランには既に追加されています"
      end

      it "上限の300件まで登録されている場合、エラーメッセージを取得すること" do
        create_list(:destination, 300, itinerary: itinerary)
        destination_params = attributes_for(:destination)
        post itinerary_destinations_path(itinerary_id: itinerary.id),
          params: { destination: destination_params }
        expect(response.body)
          .to include "このプランのスポットリストは登録数が上限に達しています"
      end
    end
  end

  describe "GET #show" do
    it "正常にレスポンスを返すこと", vcr: "google_api_response" do
      get itinerary_destination_path(itinerary_id: itinerary.id, id: destination.id)
      expect(response).to have_http_status 200
    end

    it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
      get itinerary_destination_path(itinerary_id: itinerary.id, id: destination.id)
      expect(response.body).to include "シドニー・オペラハウス"
      expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete itinerary_destination_path(itinerary_id: itinerary.id, id: destination.id)
      expect(response).to redirect_to itinerary_destinations_path
    end
  end
end
