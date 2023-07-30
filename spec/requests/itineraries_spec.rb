require 'rails_helper'

RSpec.describe "Itineraries", type: :request do
  let(:itinerary) { create(:itinerary, owner: @user) }

  context 'ログインユーザーの場合' do
    before do
      @user = create(:user)
      sign_in @user
    end

    describe "GET #index" do
      it "正常にレスポンスを返すこと" do
        get itineraries_path
        expect(response).to have_http_status 200
      end

      it "ログインユーザーの全ての旅のプランが取得できること" do
        itinerary
        other_itinerary = create(:itinerary, :other, owner: @user)
        get itineraries_path
        expect(response.body).to include itinerary.title, other_itinerary.title
      end

      it "他のユーザーのプランを取得していないこと" do
        other_user = create(:user, :other)
        other_users_itinerary = create(:itinerary, owner: other_user)
        get itineraries_path
        expect(response.body).not_to include other_users_itinerary.title
      end
    end

    describe "GET #new" do
      it "正常にレスポンスを返すこと" do
        get new_itinerary_path
        expect(response).to have_http_status 200
      end
    end

    describe "POST #create" do
      it "有効な値の場合、旅のプラン作成に成功すること" do
        itinerary_params = attributes_for(:itinerary)
        post itineraries_path, params: { itinerary: itinerary_params }
        expect(response).to redirect_to itinerary_path(Itinerary.last)
      end

      it "無効な値の場合、旅のプラン作成に失敗すること" do
        itinerary_params = attributes_for(:itinerary, title: "")
        post itineraries_path, params: { itinerary: itinerary_params }
        # expect(response.body).to include "タイトルを入力してください"
      end
    end

    describe "GET #show" do
      it "旅のプラン表示に成功すること" do
        get itinerary_path(itinerary.id)
        expect(response).to have_http_status 200
      end

      it "旅のプランの情報を取得すること" do
        get itinerary_path(itinerary.id)
        # expect(response.body).to include itinerary.title
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
        delete itinerary_path(itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end
end
