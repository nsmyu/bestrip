require 'rails_helper'

RSpec.describe "Users::Places", type: :system, focus: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    let(:user_place) { create(:user_place, :opera_house, placeable: user) }

    context "お気に入りに登録がない場合" do
      it "その旨メッセージを表示すること" do
        visit users_places_path
        expect(page).to have_content "登録されているスポットはありません"
      end
    end

    context "お気に入りに登録がある場合", js: true do
      it "登録済みのスポット全てを表示すること" do
        user_place
        create(:user_place, :queen_victoria_building, placeable: user)
        visit users_places_path

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な場合、エラーメッセージを表示すること" do
        create(:user_place, place_id: "invalid_place_id", placeable: user)
        visit users_places_path

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "スポットの名称をクリックすると、スポット情報のモーダルを表示すること" do
        user_place
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
    it "地図上の検索結果の「スポット詳細」をクリックすると、スポット情報モーダルを表示すること" do
      visit users_places_find_path
      search_place_and_open_place_modal

      within ".modal" do
        expect(page).to have_content "スポット情報"
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end
  end

  describe "お気に入り登録", js: true do
    let(:user_place) { build(:user_place, :opera_house, placeable: user) }

    context "追加登録可能な状態の場合" do
      it "成功すること（ボタンが削除用リンクに切り替わること）" do
        visit users_places_find_path
        search_place_and_open_place_modal

        expect {
          within ".modal" do
            find(:xpath, "//form[button[span[contains(text(), 'お気に入りに追加')]]]").click

            expect(page).to have_xpath "//a[span[contains(text(), 'お気に入りに追加済み')]]"
          end
        }.to change(user.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に追加されている場合、追加済みボタンが表示されること" do
        user_place.save
        visit users_places_find_path
        search_place_and_open_place_modal

        within ".modal" do
          expect(page).to have_content "お気に入りに追加済み"
        end
      end

      it "上限の300件まで登録済みの場合、その旨メッセージを表示し、追加ボタンが無効化されていること" do
        create_list(:user_place, 300, placeable: user)
        visit users_places_find_path
        search_place_and_open_place_modal

        within ".modal" do
          expect(page).to have_content "お気に入り登録数が上限に達しています"
          expect(find(:xpath, "//button[span[contains(text(), 'お気に入りに追加')]]")).to be_disabled
        end
      end
    end
  end

  describe "お気に入りから削除", js: true do
    let!(:user_place) { create(:user_place, :opera_house, placeable: user) }

    context "スポット検索画面のモーダルから削除する場合" do
      it "成功すること（ボタンが追加用フォームに切り替わること）" do
        expect {
          visit new_users_place_path(place_id: user_place.place_id)
          find(:xpath, "//a[span[contains(text(), 'お気に入りに追加済み')]]").click

          expect(page).to have_xpath "//form[button[span[contains(text(), 'お気に入りに追加')]]]"
        }.to change(user.places, :count).by(-1)
      end
    end

    context "お気に入り一覧ページから削除する場合" do
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
