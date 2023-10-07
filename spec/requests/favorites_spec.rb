require 'rails_helper'

RSpec.describe "Favorites", type: :request, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:favorite) { create(:favorite, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get itinerary_favorites_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end

    # it "旅のプランに含まれるスケジュールを全て取得すること" do
    #   schedule1 = create(:schedule, itinerary_id: itinerary.id)
    #   schedule2 = create(:schedule, itinerary_id: itinerary.id)
    #   get itinerary_schedules_path(itinerary_id: itinerary.id)
    #   expect(response.body).to include schedule1.title, schedule2.title
    # end

    # it "スケジュールのタイトル、日付、開始・終了時間を取得すること" do
    #   schedule = create(:schedule, itinerary_id: itinerary.id)
    #   get itinerary_schedules_path(itinerary_id: itinerary.id)
    #   expect(response.body).to include schedule.title
    #   expect(response.body).to include I18n.l schedule.schedule_date
    #   expect(response.body).to include I18n.l schedule.start_at
    #   expect(response.body).to include I18n.l schedule.end_at
    # end

    # it "他の旅のプランのスケジュールを取得しないこと" do
    #   other_itinerary = create(:itinerary, owner: user)
    #   other_itinerary_schedule = create(:schedule, itinerary_id: other_itinerary.id)
    #   get itinerary_schedules_path(itinerary_id: itinerary.id)
    #   expect(response.body).not_to include other_itinerary_schedule.title
    # end
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_itinerary_favorite_path(itinerary_id: itinerary.id)
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        favorite_params = attributes_for(:favorite)
        post itinerary_favorites_path(itinerary_id: itinerary.id),
          params: { favorite: favorite_params }
        expect(response.body).to include '<turbo-frame id="favorite">'
        expect(response.body).to include '行きたい場所リストに追加済み'
      end
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete itinerary_favorite_path(itinerary_id: itinerary.id, id: favorite.id)
      expect(response).to redirect_to itinerary_favorites_path
    end
  end
end
