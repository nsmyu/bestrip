require 'rails_helper'

RSpec.describe "Itineraries", type: :request, focus: true do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, bestrip_id: "other_user_id") }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }
  let(:turbo_frame_modal) { { "turbo-frame": "modal" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itineraries_path
      expect(response).to have_http_status 200
    end

    it "ログインユーザーの全ての旅のプランを取得すること" do
      other_itinerary = create(:itinerary, owner: user)
      other_users_itinerary = create(:itinerary, owner: other_user)
      other_users_itinerary.members << user
      get itineraries_path
      expect(response.body)
        .to include itinerary.title, other_itinerary.title, other_users_itinerary.title
    end

    it "旅のプランのタイトル、出発日・帰宅日、メンバー名を取得すること" do
      itinerary.members << other_user
      get itineraries_path
      expect(response.body).to include itinerary.title
      expect(response.body).to include I18n.l itinerary.departure_date
      expect(response.body).to include I18n.l itinerary.return_date
      expect(response.body).to include itinerary.owner.name, other_user.name
    end

    it "他のユーザーのプランを取得しないこと" do
      other_users_itinerary = create(:itinerary, owner: other_user)
      get itineraries_path
      expect(response.body).not_to include other_users_itinerary.title
    end
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_itinerary_path, headers: turbo_frame_modal
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        itinerary_params = attributes_for(:itinerary)
        post itineraries_path, params: { itinerary: itinerary_params }
        expect(response).to redirect_to itinerary_path(Itinerary.last)
      end
    end

    context "無効な値の場合" do
      it "必須項目が空欄の場合、失敗すること" do
        itinerary_params =
          attributes_for(:itinerary, title: "", departure_date: "", return_date: "")
        post itineraries_path, params: { itinerary: itinerary_params }, headers: turbo_stream
        expect(response.body).to include "タイトルを入力してください"
        expect(response.body).to include "出発日を入力してください"
        expect(response.body).to include "帰宅日を入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        itinerary_params = attributes_for(:itinerary, title: "a" * 31)
        post itineraries_path, params: { itinerary: itinerary_params }, headers: turbo_stream
        expect(response.body).to include "タイトルは30文字以内で入力してください"
      end

      it "帰宅日が出発日より前の日付の場合、失敗すること" do
        itinerary_params = attributes_for(:itinerary, return_date: "2024-01-31")
        post itineraries_path, params: { itinerary: itinerary_params }, headers: turbo_stream
        expect(response.body).to include "帰宅日は出発日以降で選択してください"
      end
    end
  end

  describe "GET #show" do
    context "ログインユーザーがプランのメンバーである場合" do
      before do
        get itinerary_path(itinerary.id)
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "旅のプランの情報を取得すること" do
        expect(response.body).to include itinerary.title
        expect(response.body).to include I18n.l itinerary.departure_date
        expect(response.body).to include I18n.l itinerary.return_date
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "indexにリダイレクトされること" do
        sign_in other_user
        get itinerary_path(itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #edit" do
    context "ログインユーザーがプラン作成者の場合" do
      before do
        get edit_itinerary_path(itinerary.id)
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "旅のプランの情報を取得すること" do
        expect(response.body).to include itinerary.title
        expect(response.body).to include itinerary.departure_date.to_s
        expect(response.body).to include itinerary.return_date.to_s
      end
    end

    context "ログインユーザーがプラン作成者ではない場合" do
      it "showにリダイレクトされること" do
        itinerary.members << other_user
        sign_in other_user
        get edit_itinerary_path(itinerary.id)
        expect(response).to redirect_to itinerary_path(itinerary.id)
      end
    end
  end

  describe "PATCH #update" do
    context "ログインユーザーがプラン作成者の場合" do
      context "有効な値の場合" do
        it "各項目の変更に成功すること" do
          itinerary_params = attributes_for(:itinerary, title: "Edited Title",
                                                        departure_date: "2024-04-01",
                                                        return_date: "2024-04-08")
          patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
          expect(response).to redirect_to itinerary_path(itinerary.id)
          expect(itinerary.reload.title).to eq "Edited Title"
          expect(itinerary.reload.departure_date.to_s).to eq "2024-04-01"
          expect(itinerary.reload.return_date.to_s).to eq "2024-04-08"
        end
      end

      context "無効な値の場合" do
        it "必須項目が空欄の場合、失敗すること" do
          itinerary_params =
            attributes_for(:itinerary, title: "", departure_date: "", return_date: "")
          patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params },
                                              headers: turbo_stream
          expect(response.body).to include "タイトルを入力してください"
          expect(response.body).to include "出発日を入力してください"
          expect(response.body).to include "帰宅日を入力してください"
        end

        it "タイトルが31文字以上の場合、失敗すること" do
          itinerary_params = attributes_for(:itinerary, title: "a" * 31)
          patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params },
                                              headers: turbo_stream
          expect(response.body).to include "タイトルは30文字以内で入力してください"
        end

        it "帰宅日が出発日より前の日付の場合、失敗すること" do
          itinerary_params = attributes_for(:itinerary, return_date: "2024-01-31")
          patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params },
                                              headers: turbo_stream
          expect(response.body).to include "帰宅日は出発日以降で選択してください"
        end
      end
    end

    context "ログインユーザーがプラン作成者ではない場合" do
      it "失敗すること" do
        itinerary.members << other_user
        sign_in other_user
        patch itinerary_path(itinerary.id), params: { itinerary: { title: "Edited Title" } }
        expect(response).to redirect_to itinerary_path(id: itinerary.id)
        expect(itinerary.reload.title).not_to eq "Edited Title"
      end
    end
  end

  describe "DELETE #destroy" do
    it "ログインユーザーがプラン作成者の場合、成功すること" do
      delete itinerary_path(itinerary.id)
      expect(response).to redirect_to itineraries_path
      expect(user.reload.itineraries).not_to include itinerary
    end

    it "ログインユーザーがプラン作成者ではない場合、失敗すること" do
      itinerary.members << other_user
      sign_in other_user
      delete itinerary_path(itinerary.id)
      expect(other_user.reload.itineraries).to include itinerary
    end
  end
end
