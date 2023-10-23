require "rails_helper"

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let!(:favorite) { create(:favorite, :opera_house, user: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "「行きたい場所」に登録がない場合" do
      it "メッセージを表示すること" do
        visit itinerary_destinations_path(itinerary_id: itinerary.id)

        expect(page).to have_content "行きたい場所は登録されていません"
      end
    end

    context "「行きたい場所」に登録がある場合" do
      it "登録されたスポットを全て表示すること" do
        create(:destination, :opera_house, itinerary: itinerary)
        create(:destination, :queen_victoria_building, itinerary: itinerary)
        visit itinerary_destinations_path(itinerary_id: itinerary.id)

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な（変更されている）場合、エラーメッセージを表示すること" do
        create(:destination, place_id: "invalid_place_id", itinerary: itinerary)
        visit itinerary_destinations_path(itinerary_id: itinerary.id)

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "「スケジュール作成」をクリックすると、スポット情報を含むスケジュール作成モーダルを表示すること" do
        create(:destination, :opera_house, itinerary: itinerary)
        visit itinerary_destinations_path(itinerary_id: itinerary.id)
        within(:xpath, "//div[div[p[contains(text(), 'シドニー・オペラハウス')]]]") do
          click_on "スケジュール作成"
        end

        within(".modal", match: :first) do
          expect(page).to have_content "スケジュール作成"
          expect(page).to have_content "シドニー・オペラハウス"
        end
      end
    end
  end

  describe "新規作成", js: true do
    context "有効な値の場合" do
      it "成功すること" do
        visit destinations_select_itinerary_itineraries(favorite_id: favorite.id)
        expect {
          find("#destination_itinerary_id").click
          find("option", text: "#{itinerary.title}").click
          click_on "行きたい場所に追加"

          expect(page).to have_content "行きたい場所に追加しました"
        }.to change(Destination, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "同じ旅のプランでplace_idが重複している場合、失敗すること" do
        create(:destination, :opera_house, itinerary: itinerary)
        visit destinations_select_itinerary_itineraries(favorite_id: favorite.id)

        expect {
          find("#destination_itinerary_id").click
          find("option", text: "#{itinerary.title}").click
          click_on "行きたい場所に追加"

          expect(page).to have_content "この旅のプランには既に追加されています"
        }.not_to change(Destination, :count)
      end

      it "上限の300件まで登録されている場合、失敗すること" do
        create_list(:destination, 300, itinerary_id: itinerary.id)
        visit destinations_select_itinerary_itineraries(favorite_id: favorite.id)

        expect {
          find("#destination_itinerary_id").click
          find("option", text: "#{itinerary.title}").click
          click_on "行きたい場所に追加"

          expect(page).to have_content "このプランのスポットリストは登録数が上限に達しています"
        }.not_to change(Destination, :count)
      end
    end
  end

  describe "詳細表示", js: true do
    let!(:destination) { create(:destination, :opera_house, itinerary: itinerary) }

    it "スポット情報を表示すること" do
      visit itinerary_destinations_path(itinerary_id: itinerary.id)
      within(:xpath, "//div[div[p[contains(text(), 'シドニー・オペラハウス')]]]") do
        click_on "スポット詳細"
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
    let!(:destination) { create(:destination, :opera_house, itinerary: itinerary) }

    it "成功すること" do
      expect {
        visit itinerary_destinations_path(itinerary_id: itinerary.id)
        within(:xpath, "//div[div[p[contains(text(), 'シドニー・オペラハウス')]]]") do
          find("i", text: "close").click
        end

        expect(page).to have_content "このスポットを行きたい場所から削除しますか？"

        click_on "削除する"

        expect(page).to have_content "行きたい場所から削除しました。"
        expect(current_path).to eq itinerary_destinations_path(itinerary_id: itinerary.id)
      }.to change(Destination, :count).by(-1)
    end
  end
end
