require "rails_helper"

RSpec.describe "Favorites", type: :system do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "行きたい場所リストに登録がない場合" do
      it "メッセージを表示すること" do
        visit favorites_path

        expect(page).to have_content "行きたい場所は登録されていません"
      end
    end

    context "行きたい場所リストに登録がある場合" do
      it "登録されているスポットを全て表示すること" do
        create(:favorite, :opera_house, user: user)
        create(:favorite, :queen_victoria_building, user: user)
        visit favorites_path

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な（変更されている）場合、エラーメッセージを表示すること" do
        create(:favorite, place_id: "invalid_place_id", user: user)
        visit favorites_path

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "「プランに追加」をクリックすると、旅のプランに選択して追加するためのモーダルを表示すること", js: true do
        create(:favorite, :opera_house, user: user)
        visit favorites_path
        within(:xpath, "//div[div[p[contains(text(), 'シドニー・オペラハウス')]]]") do
          click_on "プランに追加"
        end

        within(".modal", match: :first) do
          expect(page).to have_content "旅のプランに追加"
        end
      end
    end
  end

  describe "新規作成", js: true do
    let(:favorite) { build(:favorite, :opera_house, user: user) }

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          visit new_favorite_path(place_id: favorite.place_id)
          click_on "お気に入りに追加"

          expect(page).to have_content "お気に入りに追加済み"
        }.to change(Favorite, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "既にお気に入りに登録されている場合、「お気に入りに追加済み」ボタンが表示されること" do
        favorite.save
        visit new_favorite_path(place_id: favorite.place_id)

        expect(page).to have_content "お気に入りに追加済み"
      end

      it "上限の300件まで登録されている場合、メッセージが表示され、ボタンが無効化されていること" do
        create_list(:favorite, 300, user: user)
        visit new_favorite_path(place_id: favorite.place_id)

        expect(page).to have_content "※お気に入り登録上限の300件まで登録されています。"
        expect(page).to have_xpath "//input[@value='お気に入りに追加'][@disabled='disabled']"
      end
    end
  end

  describe "詳細表示", js: true do
    let!(:favorite) { create(:favorite, :opera_house, user: user) }

    it "スポット情報を表示すること" do
      visit favorites_path
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
    let!(:favorite) { create(:favorite, :opera_house, user: user) }

    context "一覧表示から削除する場合" do
      it "成功すること" do
        expect {
          visit favorites_path
          within(:xpath, "//div[div[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            find("i", text: "close").click
          end

          expect(page).to have_content "このスポットをお気に入りから削除しますか？"

          click_on "削除する"

          expect(page).to have_content "行きたい場所リストから削除しました。"
          expect(current_path).to eq favorites_path
        }.to change(Favorite, :count).by(-1)
      end
    end

    context "お気に入り追加画面から削除する場合" do
      it "成功すること（ボタンが切り替わること）" do
        expect {
          visit new_favorite_path(place_id: favorite.place_id)
          click_on "お気に入りに追加済み"

          expect(page).to have_content "お気に入りに追加"
          expect(current_path).to eq new_favorite_path
        }.to change(Favorite, :count).by(-1)
      end
    end
  end
end
