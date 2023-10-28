require 'rails_helper'

RSpec.describe "Users::Places", type: :system, focus: true do
  let!(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "お気に入り一覧表示" do
    let(:user_place) { build(:user_place, :opera_house, placeable: user) }

    context "お気に入りに登録がない場合" do
      it "その旨メッセージを表示すること" do
        visit users_places_path
        expect(page).to have_content "登録されているスポットはありません"
      end
    end

    context "お気に入りに登録がある場合", js: true do
      it "登録されているスポット全ての情報を表示すること" do
        user_place.save
        create(:user_place, :queen_victoria_building, placeable: user)
        visit users_places_path

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な（変更されている）場合、エラーメッセージを表示すること" do
        create(:user_place, place_id: "invalid_place_id", placeable: user)
        visit users_places_path

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "スポットの名称をクリックすると、スポット情報のモーダルを表示すること" do
        user_place.save
        visit users_places_path
        click_on "シドニー・オペラハウス"

        within(".modal", match: :first) do
          expect(page).to have_content "スポット情報"
          expect(page).to have_content "シドニー・オペラハウス"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        end
      end
    end
  end

  describe "スポット検索", js: true do
    it "検索結果を地図上に表示、情報ウィンドウのリンクをクリックするとスポット情報をモーダルで表示すること" do
      visit users_places_find_path
      fill_in "searchbox_text_input", with: "シドニー オペラハウス"
      sleep 0.5
      find("#searchbox_text_input").click
      all("span.pac-matched", text: "シドニー・オペラハウス")[1].click
      find("img[src*='maps.gstatic.com/mapfiles/transparent.png']").hover

      click_on "スポット詳細"

      within ".modal" do
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        expect(page).to have_content "お気に入りに追加"
      end
    end
  end

  describe "お気に入り登録", js: true do
    let(:user_place) { build(:user_place, :opera_house, placeable: user) }

    context "追加登録可能な状態の場合" do
      it "成功すること" do
        expect {
          visit new_users_place_path(place_id: user_place.place_id)
          expect(page).to have_selector "i", text: "favorite_border"
          click_on "お気に入りに追加"

          expect(page).to have_content "お気に入りに追加済み"
        }.to change(user.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に登録されている場合、追加済みボタンが表示されること" do
        user_place.save
        visit new_users_place_path(place_id: user_place.place_id)

        expect(page).to have_content "お気に入りに追加済み"
      end

      it "上限の300件まで登録済みの場合、その旨メッセージを表示すること" do
        create_list(:user_place, 300, placeable: user)
        visit new_users_place_path(place_id: user_place.place_id)

        expect(page).to have_content "お気に入り登録数が上限に達しています"
      end
    end
  end

  describe "削除", js: true do
    let!(:user_place) { create(:user_place, :opera_house, placeable: user) }

    context "スポット検索で表示したスポット情報モーダルから削除する場合" do
      it "成功すること" do
        expect {
          visit new_users_place_path(place_id: user_place.place_id)
          click_on "お気に入りに追加済み", match: :first

          expect(page).to have_selector "i", text: "favorite_border"
          expect(page).to have_content "お気に入りに追加"
        }.to change(user.places, :count).by(-1)
      end
    end

    context "お気に入り一覧画面から削除する場合" do
      it "成功すること" do
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            find("i", text: "close").click
          end

          expect(page).to have_content "このスポットを削除しますか？"

          click_on "削除する"

          expect(page).to have_content "スポットを削除しました。"
          expect(page).not_to have_content "シドニー・オペラハウス"
          expect(current_path).to eq users_places_path
        }.to change(user.places, :count).by(-1)
      end
    end
  end
end
