require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  let!(:user) { create(:user) }
  let(:favorite) { create(:favorite, :opera_house, user: user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get favorites_path
      expect(response).to have_http_status 200
    end

    it "お気に入り登録されているスポット情報を全て取得すること", vcr: "google_api_response" do
      favorite
      create(:favorite, :queen_victoria_building, user: user)
      get favorites_path
      expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
    end

    it "place_idが無効な（変更されている）場合、エラーメッセージを取得すること" do
      create(:favorite, place_id: "invalid_place_id", user: user)
      get favorites_path
      expect(response.body).to include "スポット情報を取得できませんでした"
    end
  end

  describe "GET #new" do
    context "追加登録可能な状態の場合" do
      it "正常にレスポンスを返すこと" do
        get new_favorite_path(place_id: favorite.place_id)
        expect(response).to have_http_status 200
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に登録されている場合、登録済みアイコンを取得すること" do
        favorite
        get new_favorite_path(place_id: favorite.place_id)
        expect(response.body).to include "favorite"
      end

      it "上限の300件まで登録されている場合、エラーメッセージを取得すること" do
        create_list(:favorite, 300, user: user)
        excess_avorite = build(:favorite, :opera_house, user: user)
        get new_favorite_path(place_id: excess_avorite.place_id)
        expect(response.body).to include "お気に入り登録数が上限に達しています"
      end
    end
  end

  describe "POST #create" do
    it "成功すること（ボタンのアイコンが切り替わること）" do
      favorite_params = attributes_for(:favorite)
      post favorites_path, params: { favorite: favorite_params }, headers: turbo_stream
      expect(response.body).to include "favorite"
    end
  end

  describe "GET #show" do
    it "正常にレスポンスを返すこと", vcr: "google_api_response" do
      get favorite_path(id: favorite.id)
      expect(response).to have_http_status 200
    end

    it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
      get favorite_path(id: favorite.id)
      expect(response.body).to include "シドニー・オペラハウス"
      expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
    end
  end

  describe "DELETE #destroy" do
    it "成功すること（ボタンのアイコンが切り替わること）" do
      delete favorite_path(id: favorite.id), headers: turbo_stream
      expect(response.body).to include "heart_plus"
    end
  end
end
