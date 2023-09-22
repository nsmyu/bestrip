require 'rails_helper'

RSpec.describe "Schedules", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:schedule) { create(:schedule, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end

    it "旅のプランに含まれるスケジュールを全て取得すること" do
      schedule1 = create(:schedule, itinerary_id: itinerary.id)
      schedule2 = create(:schedule, itinerary_id: itinerary.id)
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response.body).to include schedule1.title, schedule2.title
    end

    it "スケジュールのタイトル、日付、開始・終了時間を取得すること" do
      schedule = create(:schedule, itinerary_id: itinerary.id)
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response.body).to include schedule.title
      expect(response.body).to include I18n.l schedule.schedule_date
      expect(response.body).to include I18n.l schedule.start_at
      expect(response.body).to include I18n.l schedule.end_at
    end

    it "他の旅のプランのスケジュールを取得しないこと" do
      other_itinerary = create(:itinerary, owner: user)
      other_itinerary_schedule = create(:schedule, itinerary_id: other_itinerary.id)
      get itinerary_schedules_path(itinerary_id: itinerary.id)
      expect(response.body).not_to include other_itinerary_schedule.title
    end
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_itinerary_schedule_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
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
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが51文字以上の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, title: "a" * 51)
        post itinerary_schedules_path(itinerary_id: itinerary.id),
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルは50文字以内で入力してください"
      end

      it "日付が出発日より前の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-01-31")
        post itinerary_schedules_path(itinerary_id: itinerary.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end

      it "日付が帰宅日より後の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-02-09")
        post itinerary_schedules_path(itinerary_id: itinerary.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end

      it "メモが501文字以上の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, note: "a" * 501)
        post itinerary_schedules_path(itinerary_id: itinerary.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end
    end
  end

  describe "GET #show" do
    context "有効なリクエストの場合" do
      before do
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "スケジュールの情報を取得すること" do
        expect(response.body).to include schedule.title
        expect(response.body).to include schedule.icon
        expect(response.body).to include I18n.l schedule.schedule_date
        expect(response.body).to include I18n.l schedule.start_at
        expect(response.body).to include I18n.l schedule.end_at
        expect(response.body).to include schedule.note
      end

      it "スポット情報をGoogle APIから取得すること", vcr: "google_api_response" do
        expect(response.body).to include "シドニー・オペラハウス"
        expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end

    context "無効なリクエストの場合" do
      it "place_idが間違っている(変更されている)場合、エラーメッセージを取得すること", vcr: "google_api_response" do
        schedule = create(:schedule, place_id: "invalid_place_id", itinerary: itinerary)
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
        expect(response.body).to include "スポット情報を取得できませんでした"
      end
    end
  end

  describe "GET #edit" do
    context "有効なリクエストの場合" do
      before do
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "スケジュールの情報を取得すること" do
        expect(response.body).to include schedule.title
        expect(response.body).to include schedule.icon
        expect(response.body).to include I18n.l schedule.schedule_date
        expect(response.body).to include I18n.l schedule.start_at
        expect(response.body).to include I18n.l schedule.end_at
        expect(response.body).to include schedule.note
      end

      it "スポット情報をGoogle Places APIから取得すること", vcr: "google_api_response" do
        expect(response.body).to include "シドニー・オペラハウス"
        expect(response.body).to include "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end

    context "無効なリクエストの場合" do
      it "place_idが間違っている(変更されている)場合、エラーメッセージを取得すること", vcr: "google_api_response" do
        schedule = create(:schedule, place_id: "invalid_place_id", itinerary: itinerary)
        get itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
        expect(response.body).to include "スポット情報を取得できませんでした"
      end
    end
  end

  describe "PATCH #update" do
    context "有効な値の場合" do
      it "タイトルの変更に成功すること" do
        schedule_params = attributes_for(:schedule, title: "New Title")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.title).to eq "New Title"
      end

      it "日付の変更に成功すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-02-03")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.schedule_date.to_s).to eq "2024-02-03"
      end

      it "開始・終了時間の変更に成功すること" do
        schedule_params = attributes_for(:schedule, start_at: "14:00:00", end_at: "16:00:00")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.start_at.to_s).to include "14:00:00"
        expect(schedule.reload.end_at.to_s).to include "16:00:00"
      end

      it "place_idの変更に成功すること" do
        schedule_params = attributes_for(:schedule, place_id: "New_place_id")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.place_id).to eq "New_place_id"
      end

      it "アイコンの変更に成功すること" do
        schedule_params = attributes_for(:schedule, icon: "shopping_cart")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.icon).to eq "shopping_cart"
      end

      it "メモの変更に成功すること" do
        schedule_params = attributes_for(:schedule, note: "New note")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(schedule.reload.note).to eq "New note"
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、成功すること" do
        schedule_params = attributes_for(:schedule, title: "")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが51文字以上の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, title: "a" * 51)
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルは50文字以内で入力してください"
      end

      it "日付が出発日より前の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-01-31")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end

      it "日付が帰宅日より後の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-02-09")
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end

      it "メモが501文字以上の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, title: "a" * 501)
        patch itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      expect(response).to redirect_to itinerary_schedules_path
    end
  end
end
