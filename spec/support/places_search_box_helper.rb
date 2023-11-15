module PlacesSearchBoxHelper
  def search_place_and_open_place_modal
    fill_in "searchbox_text_input", with: "シドニー オペラハウス"
    sleep 0.5
    find("#searchbox_text_input").click
    all("span.pac-matched", text: "シドニー・オペラハウス")[1].click
    find("img[src*='maps.gstatic.com/mapfiles/transparent.png']").hover
    click_on "スポット詳細"
  end
end
