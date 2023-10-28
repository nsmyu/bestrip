require 'rails_helper'

RSpec.describe "Users::Places", type: :request do
  let!(:user) { create(:user) }
  let(:user_place) { build(:user_place, :opera_house, placeable: user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get users_places_path
      expect(response).to have_http_status 200
    end

    it "登録されているスポット全ての情報を取得すること", vcr: "google_api_response" do
      user_place.save
      create(:user_place, :queen_victoria_building, placeable: user)
      get users_places_index_lazy_path
      expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
    end

    it "place_idが無効な（変更されている）場合、エラーメッセージを取得すること" do
      create(:user_place, place_id: "invalid_place_id", placeable: user)
      get users_places_index_lazy_path
      expect(response.body).to include "スポット情報を取得できませんでした"
    end
  end

  describe "GET #new" do
    context "追加登録可能な状態の場合" do
      it "正常にレスポンスを返すこと" do
        get new_users_place_path(place_id: user_place.place_id)
        expect(response).to have_http_status 200
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に登録されている場合、追加済みボタンを取得すること" do
        user_place.save
        get new_users_place_path(place_id: user_place.place_id)
        expect(response.body).to include "お気に入りに追加済み"
      end

      it "上限の300件まで登録済みの場合、その旨メッセージを取得すること" do
        create_list(:user_place, 300, placeable: user)
        get new_users_place_path(place_id: user_place.place_id)
        expect(response.body).to include "お気に入り登録数が上限に達しています"
      end
    end
  end

  describe "POST #create" do
    it "成功すること" do
      user_place_params = attributes_for(:user_place)
      post users_places_path, params: { place: user_place_params }, headers: turbo_stream
      expect(response.body).to include "お気に入りに追加済み"
    end
  end

  describe "GET #show" do
    it "正常にレスポンスを返すこと", vcr: "google_api_response" do
      user_place.save
      get users_place_path(id: user_place.id)
      expect(response).to have_http_status 200
    end

    it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
      user_place.save
      get users_place_path(id: user_place.id)
      expect(response.body).to include "シドニー・オペラハウス"
      expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      user_place.save
      delete users_place_path(id: user_place.id), headers: turbo_stream
      expect(response.body).to include "お気に入りに追加\n"
    end
  end
end
