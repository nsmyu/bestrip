require 'rails_helper'

RSpec.describe "Schedules", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:itinerary1) { create(:itinerary, owner: user) }
  let!(:itinerary2) { create(:itinerary, owner: user) }
  let(:schedule) { create(:schedule, itinerary: itinerary1) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_schedules_path(itinerary_id: itinerary1.id)
      expect(response).to have_http_status 200
    end

    it "旅のプランに含まれるスケジュールを全て取得すること" do
      schedule1 = create(:schedule, itinerary_id: itinerary1.id)
      schedule2 = create(:schedule, itinerary_id: itinerary1.id)
      get itinerary_schedules_path(itinerary_id: itinerary1.id)
      expect(response.body).to include schedule1.title, schedule2.title
    end

    it "スケジュールのタイトル、日付、開始・終了時間を取得すること" do
      schedule = create(:schedule, itinerary_id: itinerary1.id)
      get itinerary_schedules_path(itinerary_id: itinerary1.id)
      expect(response.body).to include schedule.title
      expect(response.body).to include I18n.l schedule.schedule_date
      expect(response.body).to include I18n.l schedule.start_at
      expect(response.body).to include I18n.l schedule.end_at
    end

    it "他の旅のプランのスケジュールを取得しないこと" do
      itinerary2_schedule = create(:schedule, itinerary_id: itinerary2.id)
      get itinerary_schedules_path(itinerary_id: itinerary1.id)
      expect(response.body).not_to include itinerary2_schedule.title
    end
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_itinerary_schedule_path(itinerary_id: itinerary1.id)
      expect(response).to have_http_status 200
    end
  end

  describe "GET #add_place_to_schedule", focus: true do
    before do
      get itinerary_add_place_to_schedule_path(itinerary_id: itinerary1.id),
        params: { place_id: "ChIJPZ5hUjH65DQR_p_dD3CmCOo" }
    end

    # it "turbo-frameがレンダリングされること", vcr: { cassette_name: 'spot' } do
    #   expect(response.body).to include '<turbo-frame id="spot">'
    # end

    # it "スポットの名前、住所を取得すること" do
    #   place = controller.instance_variable_get('@place')
    #   expect(response.body).to include place.name
    #   expect(response.body).to include short_address(place.formatted_address)
    # end
  end

  describe "GET #remove_place_from_schedule" do
    before do
      get itinerary_remove_place_from_schedule_path(itinerary_id: itinerary1.id)
    end

    it "turbo-frameがレンダリングされること" do
      expect(response.body).to include '<turbo-frame id="spot">'
    end

    it "スポット情報を取得しないこと" do
      place = controller.instance_variable_get('@place')
      expect(place).to be nil
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        schedule_params = attributes_for(:schedule)
        post itinerary_schedules_path(itinerary_id: itinerary1.id),
          params: { schedule: schedule_params }
        expect(response).to redirect_to itinerary_schedules_path(itinerary_id: itinerary1.id)
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, title: "")
        post itinerary_schedules_path(itinerary_id: itinerary1.id),
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが51文字以上の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, title: "a" * 51)
        post itinerary_schedules_path(itinerary_id: itinerary1.id),
          params: { schedule: schedule_params }
        expect(response.body).to include "タイトルは50文字以内で入力してください"
      end

      it "日付が出発日より前の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-01-31")
        post itinerary_schedules_path(itinerary_id: itinerary1.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end

      it "日付が帰宅日より後の場合、失敗すること" do
        schedule_params = attributes_for(:schedule, schedule_date: "2024-02-09")
        post itinerary_schedules_path(itinerary_id: itinerary1.id),
          params: { schedule: schedule_params }
        expect(response).to have_http_status 422
      end
    end
  end

  describe "GET #show" do
    before do
      get itinerary_schedule_path(itinerary_id: itinerary1.id, id: schedule.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end
  end

  #   it "旅のプランの情報を取得すること" do
  #     puts itinerary.members.inspect
  #     expect(response.body).to include itinerary.title
  #     expect(response.body).to include "2024/2/1 (木)"
  #     expect(response.body).to include "2024/2/8 (木)"
  #   end

  describe "GET #edit" do
    before do
      get edit_itinerary_schedule_path(itinerary_id: itinerary1.id, id: schedule.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end
  end

  #   it "旅のプランの情報を取得すること" do
  #     expect(response.body).to include itinerary.title
  #     expect(response.body).to include itinerary.departure_date.to_s
  #     expect(response.body).to include itinerary.return_date.to_s
  #   end

  # describe "PATCH #update" do
  #   context "有効な値の場合" do
  #     it "旅のタイトルの変更に成功すること" do
  #       itinerary_params = attributes_for(:itinerary, title: "New Title")
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response).to redirect_to itinerary_path(itinerary.id)
  #       expect(itinerary.reload.title).to eq "New Title"
  #     end

  #     it "出発日、帰宅日の変更に成功すること" do
  #       itinerary_params =
  #         attributes_for(:itinerary, departure_date: "2024-04-01", return_date: "2024-04-08")
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response).to redirect_to itinerary_path(itinerary.id)
  #       expect(itinerary.reload.departure_date.to_s).to eq "2024-04-01"
  #       expect(itinerary.reload.return_date.to_s).to eq "2024-04-08"
  #     end
  #   end

  #   context "無効な値の場合" do
  #     it "必須項目が空欄の場合、失敗すること" do
  #       itinerary_params =
  #         attributes_for(:itinerary, title: "", departure_date: "", return_date: "")
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response.body).to include "タイトルを入力してください"
  #       expect(response.body).to include "出発日を入力してください"
  #       expect(response.body).to include "帰宅日を入力してください"
  #     end

  #     it "タイトルが31文字以上の場合、失敗すること" do
  #       itinerary_params = attributes_for(:itinerary, title: "a" * 31)
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response.body).to include "タイトルは30文字以内で入力してください"
  #     end

  #     it "タイトルが同じユーザーで重複している場合、失敗すること" do
  #       other_itinerary = create(:itinerary, title: "Other Trip", owner: user)
  #       itinerary_params = attributes_for(:itinerary, title: other_itinerary.title)
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response.body).to include "このタイトルはすでに使用されています"
  #     end

  #     it "帰宅日が出発日より前の日付の場合、失敗すること" do
  #       itinerary_params = attributes_for(:itinerary, return_date: "2024-01-31")
  #       patch itinerary_path(itinerary.id), params: { itinerary: itinerary_params }
  #       expect(response.body).to include "帰宅日は出発日以降で選択してください"
  #     end
  #   end
  # end

  # describe "DELETE #destroy" do
  #   it "作成者は旅のプランを削除できること" do
  #     delete itinerary_path(itinerary.id)
  #     expect(response).to redirect_to itineraries_path
  #   end

  #   it "作成者以外は旅のプランを削除できないこと" do
  #     itinerary.members << other_user1
  #     sign_out user
  #     sign_in other_user1
  #     delete itinerary_path(itinerary.id)
  #     expect(other_user1.itineraries).to include itinerary
  #   end
  # end
end
