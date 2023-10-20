require 'rails_helper'

RSpec.describe "Destinations", type: :request do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:destination) { create(:destination, :opera_house, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_destinations_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end

    it "行きたい場所リストを全て取得すること", vcr: "google_api_response" do
      destination
      create(:destination, :queen_victoria_building, itinerary: itinerary)
      get itinerary_destinations_path(itinerary_id: itinerary.id)
      expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
    end

    it "他の旅のプランのスケジュールを取得しないこと", vcr: "google_api_response" do
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

  describe "GET #new" do
    context "行きたい場所リストに登録可能な場合" do
      it "正常にレスポンスを返すこと", vcr: "google_api_response" do
        get new_itinerary_destination_path(itinerary_id: itinerary.id,
                                           place_id: destination.place_id)
        expect(response).to have_http_status 200
      end

      it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
        get new_itinerary_destination_path(itinerary_id: itinerary.id,
                                           place_id: destination.place_id)
        expect(response.body).to include "シドニー・オペラハウス"
        expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end

    context "行きたい場所リストに登録不可能な場合" do
      it "既に登録済みの場合、メッセージを取得すること" do
        destination
        get new_itinerary_destination_path(itinerary_id: itinerary.id,
                                           place_id: destination.place_id)
        expect(response.body).to include "行きたい場所リストに追加済み"
      end

      it "上限の300件まで登録されている場合、メッセージを取得すること" do
        create_list(:destination, 300, itinerary: itinerary)
        new_destination = build(:destination, :opera_house)
        get new_itinerary_destination_path(itinerary_id: itinerary.id,
                                           place_id: new_destination.place_id)
        expect(response.body).to include "ひとつの旅のプランにつき、行きたい場所リストへの登録は300件までです。"
      end
    end
  end

  describe "POST #create" do
    it "成功すること" do
      destination_params = attributes_for(:destination)
      post itinerary_destinations_path(itinerary_id: itinerary.id),
        params: { destination: destination_params }
      expect(response.body).to include '<turbo-frame id="destination">'
      expect(response.body).to include '行きたい場所リストに追加済み'
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
