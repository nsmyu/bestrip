require 'rails_helper'

RSpec.describe "Schedules", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:schedule) { create(:schedule, itinerary: itinerary) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }
  let(:turbo_frame_modal) { { "turbo-frame": "modal" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    context "ログインユーザーがプランのメンバーである場合" do
      it "正常にレスポンスを返すこと" do
        get itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(response).to have_http_status 200
      end

      it "旅のプランに含まれるスケジュールを全て取得すること" do
        schedule
        other_schedule = create(:schedule, itinerary_id: itinerary.id)
        get itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(response.body).to include schedule.title, other_schedule.title
      end

      it "スケジュールのタイトル、日付、開始・終了時間を取得すること" do
        schedule
        get itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(response.body).to include schedule.title
        expect(response.body).to include I18n.l schedule.date
        expect(response.body).to include I18n.l schedule.start_at
        expect(response.body).to include I18n.l schedule.end_at
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_in other_user
        get itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #new" do
    it "ログインユーザーがプランのメンバーである場合、正常にレスポンスを返すこと" do
      get new_itinerary_schedule_path(itinerary_id: itinerary.id), headers: turbo_frame_modal
      expect(response).to have_http_status 200
    end

    it "ログインユーザーがプランのメンバーではない場合、旅のプラン一覧画面にリダイレクトされること" do
      sign_out user
      sign_in other_user
      get new_itinerary_schedule_path(itinerary_id: itinerary.id), headers: turbo_frame_modal
      expect(response).to redirect_to itineraries_path
    end
  end

  describe "POST #create" do
    context "ログインユーザーがプランのメンバーである場合" do
      context "有効な値の場合" do
        it "成功すること" do
          schedule_params = attributes_for(:schedule)
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }
          expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        end
      end

      context "無効な値の場合" do
        it "タイトルが空欄の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, title: "")
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "タイトルを入力してください"
        end

        it "タイトルが51文字以上の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, title: "a" * 51)
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "タイトルは50文字以内で入力してください"
        end

        it "日付が出発日より前の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, date: "2024-01-31")
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end

        it "日付が帰宅日より後の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, date: "2024-02-09")
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end

        it "メモが501文字以上の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, note: "a" * 501)
          post itinerary_schedules_path(itinerary_id: itinerary.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "失敗すること（旅のプラン一覧画面にリダイレクトされること）" do
        sign_out user
        sign_in other_user
        schedule_params = attributes_for(:schedule)
        post itinerary_schedules_path(itinerary_id: itinerary.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #show" do
    before do
      get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
        headers: turbo_frame_modal
    end

    context "ログインユーザーがプランのメンバーである場合" do
      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "スケジュールの各情報を取得すること" do
        expect(response.body).to include schedule.title
        expect(response.body).to include schedule.icon
        expect(response.body).to include I18n.l schedule.date
        expect(response.body).to include I18n.l schedule.start_at
        expect(response.body).to include I18n.l schedule.end_at
        expect(response.body).to include schedule.note
      end

      it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
        expect(response.body).to include "シドニー・オペラハウス"
      end

      it "place_idが無効な場合、エラーメッセージを取得すること", vcr: "google_api_response" do
        schedule.place_id = "invalid_place_id"
        schedule.save
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          headers: turbo_frame_modal
        expect(response.body).to include "スポット情報を取得できませんでした"
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_out user
        sign_in other_user
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          headers: turbo_frame_modal
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "GET #edit" do
    context "ログインユーザーがプランのメンバーである場合" do
      before do
        get edit_itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          headers: turbo_frame_modal
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "スケジュールの各情報を取得すること" do
        expect(response.body).to include schedule.title
        expect(response.body).to include schedule.icon
        expect(response.body).to include schedule.date.to_s
        expect(response.body).to include schedule.start_at.strftime("%-H:%M")
        expect(response.body).to include schedule.end_at.strftime("%-H:%M")
        expect(response.body).to include schedule.note
      end

      it "スポット情報をGoogle Places APIから取得すること", vcr: "google_api_response" do
        expect(response.body).to include "シドニー・オペラハウス"
      end

      it "place_idが無効な場合、エラーメッセージを取得すること", vcr: "google_api_response" do
        schedule.place_id = "invalid_place_id"
        schedule.save
        get edit_itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          headers: turbo_frame_modal
        expect(response.body).to include "スポット情報を取得できませんでした"
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "旅のプラン一覧画面にリダイレクトされること" do
        sign_out user
        sign_in other_user
        get edit_itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          headers: turbo_frame_modal
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "PATCH #update" do
    context "ログインユーザーがプランのメンバーである場合" do
      context "有効な値の場合" do
        it "各項目の変更に成功すること" do
          schedule_params = attributes_for(:schedule, title: "Edited Title",
                                                      date: "2024-02-03",
                                                      start_at: "14:00:00",
                                                      end_at: "16:00:00",
                                                      place_id: "edited_place_id",
                                                      icon: "shopping_cart",
                                                      note: "Edited note")
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }
          expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
          expect(schedule.reload.title).to eq "Edited Title"
          expect(schedule.reload.date.to_s).to eq "2024-02-03"
          expect(schedule.reload.start_at.to_s).to include "14:00:00"
          expect(schedule.reload.end_at.to_s).to include "16:00:00"
          expect(schedule.reload.place_id).to eq "edited_place_id"
          expect(schedule.reload.icon).to eq "shopping_cart"
          expect(schedule.reload.note).to eq "Edited note"
        end
      end

      context "無効な値の場合" do
        it "タイトルが空欄の場合、成功すること" do
          schedule_params = attributes_for(:schedule, title: "")
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "タイトルを入力してください"
        end

        it "タイトルが51文字以上の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, title: "a" * 51)
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "タイトルは50文字以内で入力してください"
        end

        it "日付が出発日より前の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, date: "2024-01-31")
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end

        it "日付が帰宅日より後の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, date: "2024-02-09")
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end

        it "メモが501文字以上の場合、失敗すること" do
          schedule_params = attributes_for(:schedule, title: "a" * 501)
          patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
            params: { schedule: schedule_params }, headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
        end
      end
    end

    context "ログインユーザーがプランのメンバーではない場合" do
      it "失敗すること（旅のプラン一覧画面にリダイレクトされること）" do
        sign_out user
        sign_in other_user
        schedule_params = attributes_for(:schedule, title: "Edited Title")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }, headers: turbo_stream
        expect(response).to redirect_to itineraries_path
      end
    end
  end

  describe "DELETE #destroy" do
    it "ログインユーザーがプランのメンバーである場合、成功すること" do
      delete itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      expect(response).to redirect_to itinerary_schedules_path
    end

    it "ログインユーザーがプランのメンバーではない場合、失敗すること" do
      sign_out user
      sign_in other_user
      delete itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      expect(response).to redirect_to itineraries_path
    end
  end
end
