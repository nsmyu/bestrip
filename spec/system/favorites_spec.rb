require "rails_helper"

RSpec.describe "Favorites", type: :system, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "行きたい場所リストに登録がない場合" do
      it "メッセージを表示すること" do
        visit itinerary_favorites_path(itinerary_id: itinerary.id)

        expect(page).to have_content "行きたい場所は登録されていません"
      end
    end

    context "行きたい場所リストに登録がある場合" do
      it "行きたい場所リストを全て表示すること" do
        create(:favorite, :opera_house, itinerary: itinerary)
        create(:favorite, :queen_victoria_building, itinerary: itinerary)
        visit itinerary_favorites_path(itinerary_id: itinerary.id)

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な（変更されている）場合、エラーメッセージを表示すること" do
        create(:favorite, place_id: "invalid_place_id", itinerary: itinerary)
        visit itinerary_favorites_path(itinerary_id: itinerary.id)

        expect(page).to have_content "スポット情報を取得できませんでした"
      end
    end
  end

  describe "新規作成", js: true do
    let(:favorite) { build(:favorite, :opera_house, itinerary: itinerary) }

    context "行きたい場所リストに登録可能な場合" do
      it "成功すること" do
        visit new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect {
          expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
          expect(page).to have_content "シドニー・オペラハウス"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
          expect(page).to have_content "(02) 9250 7111"
          expect(page).to have_selector "a", text: "Google Mapで見る"
          expect(page).to have_selector "a", text: "公式サイト"

          click_on "行きたい場所リストに追加する"

          expect(page).to have_content "行きたい場所リストに追加済み"
        }.to change(Favorite, :count).by(1)
      end
    end

    context "行きたい場所リストに登録不可能な場合" do
      it "既に登録済みの場合、メッセージを取得することと" do
        favorite.save
        visit new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect(page).to have_content "行きたい場所リストに追加済み"
      end

      it "上限の300件まで登録されている場合、メッセージを取得すること" do
        create_list(:favorite, 300, itinerary_id: itinerary.id)
        visit new_itinerary_favorite_path(itinerary_id: itinerary.id, place_id: favorite.place_id)
        expect(page).to have_content "ひとつの旅のプランにつき、行きたい場所リストへの登録は300件までです。"
      end
    end
  end

  describe "詳細表示", js: true do
    let!(:favorite) { create(:favorite, :opera_house, itinerary: itinerary) }

    it "スポット情報を表示すること" do
      visit itinerary_favorites_path(itinerary_id: itinerary.id)
      within(:xpath, "//div[p[contains(text(), 'シドニー・オペラハウス')]]") do
        click_on "スポット情報を見る"
      end

      expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
      expect(page).to have_content "シドニー・オペラハウス"
      expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
      expect(page).to have_content "(02) 9250 7111"
      expect(page).to have_selector "a", text: "Google Mapで見る"
      expect(page).to have_selector "a", text: "公式サイト"
    end
  end

  describe "削除", js: true do
    let!(:favorite) { create(:favorite, :opera_house, itinerary: itinerary) }

    it "成功すること" do
      expect {
        visit itinerary_favorites_path(itinerary_id: itinerary.id)
        within(:xpath, "//div[p[contains(text(), 'シドニー・オペラハウス')]]") do
          find("i", text: "delete").click
        end

        expect(page).to have_content "このスポットを行きたい場所リストから削除しますか？"

        click_on "削除する"

        expect(page).to have_content "行きたい場所リストから削除しました。"
        expect(current_path).to eq itinerary_favorites_path(itinerary_id: itinerary.id)
      }.to change(Favorite, :count).by(-1)
    end
  end
end
