require "rails_helper"

RSpec.describe "SearchPlaces", type: :system do
  let!(:user) { create(:user) }

  describe "スポット検索", js: true do
    it "検索結果を地図上に表示、クリックするとスポット情報をモーダルで表示すること" do
      sign_in user
      visit search_places_path
      fill_in "searchbox_text_input", with: "シドニー オペラハウス"
      sleep 0.5
      find("#searchbox_text_input").click
      find("span.pac-matched", text: "シドニー・オペラハウス", match: :first).click
      find("img[src*='maps.gstatic.com/mapfiles/transparent.png']").hover

      click_on "スポット情報を見る"

      within ".modal" do
        expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        expect(page).to have_content "(02) 9250 7111"
        expect(page).to have_selector "a", text: "Google Mapで見る"
        expect(page).to have_selector "a", text: "公式サイト"
      end
    end
  end
end
