require 'rails_helper'

RSpec.describe "SearchPlaces", type: :request, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      sign_in user
      get search_places_itinerary_path(id: itinerary.id)
      expect(response).to have_http_status 200
    end
  end
end
