require 'rails_helper'

RSpec.describe "Itineraries::Places", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:itinerary_place) { build(:itinerary_place, :opera_house, placeable: itinerary) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }
  let(:turbo_frame_modal) { { "turbo-frame": "modal" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "正常にレスポンスを返すこと" do
        get itinerary_places_path(itinerary_id: itinerary.id)
        expect(response).to have_http_status 200
      end

      it "登録済みのスポット全てを取得すること", vcr: "google_api_response" do
        itinerary_place.save
        create(:itinerary_place, :queen_victoria_building, placeable: itinerary)
        get itinerary_places_index_lazy_path(itinerary_id: itinerary.id)
        expect(response.body).to include "シドニー・オペラハウス", "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な場合、エラーメッセージを取得すること" do
        create(:itinerary_place, place_id: "invalid_place_id", placeable: itinerary)
        get itinerary_places_index_lazy_path(itinerary_id: itinerary.id)
        expect(response.body).to include "スポット情報を取得できませんでした"
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_in other_user
        get itinerary_places_path(itinerary_id: itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #new" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "正常にレスポンスを返すこと" do
        get new_itinerary_place_path(itinerary_id: itinerary.id,
                                     place_id: itinerary_place.place_id)
        expect(response).to have_http_status 200
      end

      context "追加登録可能な状態の場合" do
        it "行きたい場所リスト追加用ボタンを取得すること" do
          get new_itinerary_place_path(itinerary_id: itinerary.id,
                                      place_id: itinerary_place.place_id)
          expect(response.body).to include "行きたい場所リストに追加</span>"
        end
      end

      context "追加登録不可能な状態の場合" do
        it "place_idが既に登録されている場合、追加済みボタンを取得すること" do
          itinerary_place.save
          get new_itinerary_place_path(itinerary_id: itinerary.id,
                                       place_id: itinerary_place.place_id)
          expect(response.body).to include "行きたい場所リストに追加済み"
        end

        it "上限の300件まで登録済みの場合、その旨メッセージを取得すること" do
          create_list(:itinerary_place, 300, placeable: itinerary)
          get new_itinerary_place_path(itinerary_id: itinerary.id,
                                       place_id: itinerary_place.place_id)
          expect(response.body).to include "行きたい場所リストの登録数が上限に達しています。"
        end
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_in other_user
        get new_itinerary_place_path(itinerary_id: itinerary.id, place_id: itinerary_place.place_id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "POST #create" do
    it "ログインユーザーがプランのメンバーである場合、成功すること" do
      itinerary_place_params = attributes_for(:itinerary_place)
      post itinerary_places_path(itinerary_id: itinerary.id),
        params: { place: itinerary_place_params }, headers: turbo_stream
      expect(response.body).to include "行きたい場所リストに追加済み"
    end

    it "ログインユーザーがプランのメンバーではない場合、失敗すること（旅のプラン一覧画面にリダイレクトされること）" do
      sign_in other_user
      itinerary_place_params = attributes_for(:itinerary_place)
      post itinerary_places_path(itinerary_id: itinerary.id),
        params: { place: itinerary_place_params }, headers: turbo_stream
      expect(response).to redirect_to itineraries_path
    end
  end

  describe "GET #show" do
    before do
      itinerary_place.save
    end

    it "正常にレスポンスを返すこと", vcr: "google_api_response" do
      get itinerary_place_path(itinerary_id: itinerary.id, id: itinerary_place.id),
        headers: turbo_frame_modal
      expect(response).to have_http_status 200
    end

    it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
      get itinerary_place_path(itinerary_id: itinerary.id, id: itinerary_place.id),
        headers: turbo_frame_modal
      expect(response.body).to include "シドニー・オペラハウス"
    end
  end

  describe "GET #select_itinerary" do
    it "正常にレスポンスを返すこと" do
      get places_select_itinerary_itineraries_path(place_id: itinerary_place.place_id)
      expect(response).to have_http_status 200
    end

    it "ログインユーザーが所有または所属する旅のプラン全てを取得すること" do
      other_itinerary_1 = create(:itinerary, owner: user)
      other_itinerary_2 = create(:itinerary, owner: other_user)
      other_itinerary_2.members << user
      get places_select_itinerary_itineraries_path(place_id: itinerary_place.place_id)
      expect(response.body)
        .to include itinerary.title, other_itinerary_1.title, other_itinerary_2.title
    end
  end

  describe "POST #add_from_user_places" do
    context "ログインユーザーがプランのメンバーである場合" do
      context "有効な値の場合" do
        it "成功すること" do
          itinerary_place_params = attributes_for(:itinerary_place)
          post itinerary_places_add_from_user_places_path(itinerary_id: itinerary.id),
            params: { place: itinerary_place_params }
          expect(response.body).to include "選択したプランの行きたい場所リストに追加しました"
        end
      end

      context "無効な値の場合" do
        it "place_idが既に登録されている場合、失敗すること" do
          itinerary_place.save
          itinerary_place_params = attributes_for(:itinerary_place,
                                                  place_id: itinerary_place.place_id)
          post itinerary_places_add_from_user_places_path(itinerary_id: itinerary.id),
            params: { place: itinerary_place_params }
          expect(response.body).to include "既に追加されています"
        end

        it "上限の300件まで登録済みの場合、失敗すること" do
          create_list(:itinerary_place, 300, placeable: itinerary)
          itinerary_place_params = attributes_for(:itinerary_place)
          post itinerary_places_add_from_user_places_path(itinerary_id: itinerary.id),
            params: { place: itinerary_place_params }
          expect(response.body).to include "スポットの登録数が上限に達しています"
        end
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "失敗すること（旅のプラン一覧画面にリダイレクトされること）" do
        sign_in other_user
        itinerary_place_params = attributes_for(:itinerary_place)
        post itinerary_places_add_from_user_places_path(itinerary_id: itinerary.id),
          params: { place: itinerary_place_params }
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      itinerary_place.save
    end

    it "ログインユーザーがプランのメンバーである場合、成功すること" do
      delete itinerary_place_path(itinerary_id: itinerary.id, id: itinerary_place.id),
        headers: turbo_stream
      expect(itinerary.reload.places).not_to include itinerary_place
    end

    it "ログインユーザーがプランのメンバーではない場合、失敗すること" do
      sign_in other_user
      delete itinerary_place_path(itinerary_id: itinerary.id, id: itinerary_place.id),
        headers: turbo_stream
      expect(itinerary.reload.places).to include itinerary_place
    end
  end
end
