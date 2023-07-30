require 'rails_helper'

RSpec.describe "Itineraries", type: :request do
  let(:itinerary) { build(:itinerary) }

  context 'ログインユーザーの場合' do
    before do
      @user = create(:user)
      sign_in @user
    end

    describe "GET #index" do
      it "旅のプラン一覧の表示に成功すること" do
        get itineraries_path
        expect(response).to have_http_status 200
      end
    end

    describe "GET #new" do
      it "旅のプラン作成画面に成功すること" do
        get new_itinerary_path
        expect(response).to have_http_status 200
      end
    end

    describe "POST #create" do
      it "有効な値の場合、旅のプラン作成に成功すること" do
        post itineraries_path, params: { itinerary: attributes_for(:itinerary) }
        expect(response).to redirect_to itinerary_path(Itinerary.last)
      end

      it "無効な値の場合、旅のプラン作成に失敗すること" do
        itinerary_params = attributes_for(:itinerary, :without_title)
        post itineraries_path, params: { itinerary: itinerary_params}
        # expect(response.body).to include "タイトルを入力してください"
      end
    end

    describe "GET #show" do
      it "旅のプラン表示に成功すること" do
        itinerary = create(:itinerary, owner: @user)
        get itinerary_path(itinerary.id)
        expect(response).to have_http_status 200
      end
    end

    # describe "GET #edit" do
    #   it "有効な値の場合、旅のプラン作成に成功すること" do
    #     post itineraries_path, params: { itinerary: attributes_for(:itinerary) }
    #     expect(response).to redirect_to itinerary_path(Itinerary.last)
    #   end
    # end

    # describe "PATCH #update" do
    #   it "有効な値の場合、旅のプラン作成に成功すること" do
    #     post itineraries_path, params: { itinerary: attributes_for(:itinerary) }
    #     expect(response).to redirect_to itinerary_path(Itinerary.last)
    #   end
    # end

    # describe "PATCH #update" do
    #   it "有効な値の場合、旅のプラン作成に成功すること" do
    #     post itineraries_path, params: { itinerary: attributes_for(:itinerary) }
    #     expect(response).to redirect_to itinerary_path(Itinerary.last)
    #   end
    # end

    describe "DELETE #destroy" do
      it "旅のプランを削除できること" do
        itinerary = create(:itinerary, owner: @user)
        delete itinerary_path(itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end
end
