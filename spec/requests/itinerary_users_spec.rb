require 'rails_helper'

RSpec.describe "ItineraryUsers", type: :request do
  let(:owner) { create(:user) }
  let(:user_1) { create(:user, bestrip_id: "bestrip_id") }
  let(:user_2) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: owner) }

  before do
    sign_in owner
  end

  describe "GET #find_by_bestrip_id" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "正常にレスポンスを返すこと" do
        get find_by_bestrip_id_itinerary_path(itinerary.id)
        expect(response).to have_http_status 200
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "indexにリダイレクトされること" do
        sign_in user_1
        get find_by_bestrip_id_itinerary_path(itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #search_user" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "検索したBesTrip IDのユーザーのニックネームを取得すること" do
        user_search_params = { bestrip_id: user_1.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include user_1.name
      end

      it "検索したBesTrip IDのユーザーが存在しない場合、メッセージを返すこと" do
        user_search_params = { bestrip_id: "no_user_id", id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include "ユーザーが見つかりませんでした"
      end

      it "検索したBesTrip IDのユーザーが既にメンバーに含まれている場合、その旨メッセージを返すこと" do
        itinerary.members << user_1
        user_search_params = { bestrip_id: user_1.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response.body).to include "すでにメンバーに含まれています"
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_in user_1
        user_search_params = { bestrip_id: user_2.bestrip_id, id: itinerary.id }
        get search_user_itinerary_path(itinerary.id), params: user_search_params
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "POST #create" do
    describe "BesTrip ID検索からメンバーを追加" do
      context "ログインユーザーがプランのメンバーである場合" do
        it "招待中ではないユーザーの追加に成功すること" do
          add_member_params = { user_id: user_1.id, id: itinerary.id }
          post itinerary_users_path(itinerary.id), params: add_member_params
          expect(response).to redirect_to itinerary_path(itinerary.id)
          expect(itinerary.reload.members).to include user_1
        end

        it "招待中のユーザーの追加に成功すること" do
          create(:pending_invitation, user: user_1, itinerary: itinerary)
          add_member_params = { user_id: user_1.id, id: itinerary.id }
          post itinerary_users_path(itinerary.id), params: add_member_params
          expect(response).to redirect_to itinerary_path(itinerary.id)
          expect(itinerary.reload.members).to include user_1
          expect(itinerary.reload.invitees).not_to include user_1
        end
      end

      context "ログインユーザーがプランのメンバーではない場合" do
        it "失敗すること" do
          sign_in user_1
          add_member_params = { user_id: user_2.id, id: itinerary.id }
          post itinerary_users_path(itinerary.id), params: add_member_params
          expect(itinerary.reload.members).not_to include user_2
        end
      end
    end

    describe "メールでの招待から旅のプランに参加" do
      it "成功すること" do
        create(:pending_invitation, user: user_1, itinerary: itinerary)
        sign_in user_1
        join_member_params = { user_id: user_1.id, id: itinerary.id }
        post itinerary_users_path(itinerary.id), params: join_member_params
        expect(response).to redirect_to itineraries_path
        expect(itinerary.reload.members).to include user_1
        expect(itinerary.reload.invitees).not_to include user_1
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      itinerary.members << user_1 << user_2
    end

    context "削除可能な場合" do
      it "ログインユーザーがプラン作成者の場合、成功すること" do
        remove_member_params = { user_id: user_1.id, id: itinerary.id }
        delete itinerary_user_path(itinerary.id), params: remove_member_params
        expect(response).to redirect_to itinerary_path(itinerary.id)
        expect(itinerary.reload.members).not_to include user_1
      end
    end

    context "削除不可能な場合" do
      it "ログインユーザーがプラン作成者ではない場合、失敗すること" do
        sign_in user_1
        remove_member_params = { user_id: user_2.id, id: itinerary.id }
        delete itinerary_user_path(itinerary.id), params: remove_member_params
        expect(itinerary.reload.members).to include user_2
      end

      it "削除対象がプラン作成者の場合、失敗すること" do
        sign_in user_1
        remove_member_params = { user_id: owner.id, id: itinerary.id }
        delete itinerary_user_path(itinerary.id), params: remove_member_params
        expect(itinerary.reload.members).to include owner
      end
    end
  end
end
