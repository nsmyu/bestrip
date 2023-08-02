require 'rails_helper'

RSpec.describe "Itineraries", type: :request, focus: true do
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
      it "有効な値の場合、旅のプラン新規作成に成功すること" do
        itinerary_params = attributes_for(:itinerary)
        post itineraries_path, params: { itinerary: itinerary_params }
        expect(response).to redirect_to itinerary_path(Itinerary.last)
      end

      it "無効な値の場合、旅のプラン新規作成に失敗すること" do
        itinerary_params = attributes_for(:itinerary, title: "")
        post itineraries_path, params: { itinerary: itinerary_params }
        expect(response.body).to include "タイトルを入力してください"
      end
    end

    describe "GET #show" do
      it "正常にレスポンスを返すこと" do
        get itinerary_path(itinerary.id)
        expect(response).to have_http_status 200
      end

      it "旅のプランの情報を取得すること" do
        get itinerary_path(itinerary.id)
        aggregate_failures do
          expect(response.body).to include itinerary.title
          expect(response.body).to include "2024/2/1"
          expect(response.body).to include "2024/2/8"
        end
      end
    end

    describe "GET #edit" do
      it "正常にレスポンスを返すこと" do
        get edit_itinerary_path(itinerary.id)
        expect(response).to have_http_status 200
      end

      it "旅のプランの情報を取得すること" do
        get edit_itinerary_path(itinerary.id)
        aggregate_failures do
          expect(response.body).to include itinerary.title
          expect(response.body).to include itinerary.departure_date.to_s
          expect(response.body).to include itinerary.return_date.to_s
        end
      end
    end

    describe "PATCH #update" do
      it "旅のタイトルを変更できること" do
        itinerary_params = attributes_for(:itinerary, title: "New Title")
        patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
        expect(itinerary.reload.title).to eq "New Title"
      end

      it "出発日と帰宅日を変更できること" do
        itinerary_params = attributes_for(:itinerary, departure_date: "2024-04-01", return_date: "2024-04-08")
        patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
        aggregate_failures do
          expect(itinerary.reload.departure_date.to_s).to eq "2024-04-01"
          expect(itinerary.reload.return_date.to_s).to eq "2024-04-08"
        end
      end

      it "旅のプラン情報ページにリダイレクトすること" do
        itinerary_params = attributes_for(:itinerary)
        patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
        expect(response).to redirect_to itinerary_path(itinerary.id)
      end

      it "必須項目が空欄の場合は失敗すること" do
        itinerary_params = attributes_for(:itinerary, title: "", departure_date: "", return_date: "")
        patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
        aggregate_failures do
          expect(response.body).to include "タイトルを入力してください"
          expect(response.body).to include "出発日を入力してください"
          expect(response.body).to include "帰宅日を入力してください"
        end
      end
    end

    describe "DELETE #destroy" do
      it "旅のプランを削除できること" do
        delete itinerary_path(itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end
end
