require 'rails_helper'

RSpec.describe "Itineraries::Places", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    let(:itinerary_place) { create(:itinerary_place, :opera_house, placeable: itinerary) }

    context "行きたい場所リストに登録がない場合" do
      it "その旨メッセージを表示すること" do
        visit itinerary_places_path(itinerary_id: itinerary.id)
        expect(page).to have_content "登録されているスポットはありません"
      end
    end

    context "行きたい場所リストに登録がある場合", js: true do
      it "登録済みのスポット全てを表示すること" do
        itinerary_place
        create(:itinerary_place, :queen_victoria_building, placeable: itinerary)
        visit itinerary_places_path(itinerary_id: itinerary.id)

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な場合、エラーメッセージを表示すること" do
        create(:itinerary_place, place_id: "invalid_place_id", placeable: itinerary)
        visit itinerary_places_path(itinerary_id: itinerary.id)

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "スポットの名称をクリックすると、スポット情報のモーダルを表示すること" do
        itinerary_place
        visit itinerary_places_path(itinerary_id: itinerary.id)
        click_on "シドニー・オペラハウス"

        within(".modal", match: :first) do
          expect(page).to have_content "スポット情報"
          expect(page).to have_content "シドニー・オペラハウス"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        end
      end

      it "「スケジュールに追加」をクリックすると、スポット情報の入ったスケジュール作成モーダルを表示すること" do
        itinerary_place
        visit itinerary_places_path(itinerary_id: itinerary.id)
        within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
          click_on "スケジュールに追加"
        end

        within(".modal", match: :first) do
          expect(page).to have_content "スケジュール作成"
          expect(page).to have_content "シドニー・オペラハウス"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        end
      end
    end
  end

  describe "スポット検索", js: true do
    it "地図上の検索結果の「スポット詳細」をクリックすると、スポット情報モーダルを表示すること", focus: true do
      visit itinerary_places_find_path(itinerary_id: itinerary.id)
      search_place_and_open_place_modal

      within ".modal" do
        expect(page).to have_content "スポット情報"
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
      end
    end
  end

  describe "行きたい場所リストへの登録", js: true, focus: true do
    let(:itinerary_place) { build(:itinerary_place, :opera_house, placeable: itinerary) }

    context "追加登録可能な状態の場合" do
      it "成功すること" do
        visit itinerary_places_find_path(itinerary_id: itinerary.id)
        search_place_and_open_place_modal

        expect {
          within ".modal" do
            click_on "行きたい場所リストに追加"

            expect(page).to have_content "行きたい場所リストに追加済み"
          end
        }.to change(itinerary.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に追加されている場合、追加済みボタンが表示されること" do
        itinerary_place.save
        visit itinerary_places_find_path(itinerary_id: itinerary.id,
                                         place_id: itinerary_place.place_id)
        search_place_and_open_place_modal

        within ".modal" do
          expect(page).to have_content "行きたい場所リストに追加済み"
        end
      end

      it "上限の300件まで登録済みの場合、その旨メッセージを表示すること" do
        create_list(:itinerary_place, 300, placeable: itinerary)
        visit itinerary_places_find_path(itinerary_id: itinerary.id,
                                         place_id: itinerary_place.place_id)
        search_place_and_open_place_modal

        within ".modal" do
          expect(page).to have_content "行きたい場所リストの登録数が上限に達しています。"
        end
      end
    end
  end

  describe "お気に入り一覧から、プランを選択して行きたい場所リストへ追加", js: true do
    let!(:user_place) { create(:user_place, :opera_house, placeable: user) }

    context "追加登録可能な状態の場合" do
      it "成功すること（追加後、行きたい場所リストへのリンクを表示すること）" do
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "行きたい場所リストに追加"

            expect(page).to have_content "選択したプランの行きたい場所リストに追加しました"

            click_on "プランを確認"
          end

          expect(page).to have_content itinerary.title
          expect(page).to have_content "シドニー・オペラハウス"
          expect(current_path).to eq itinerary_places_path(itinerary_id: itinerary.id)
        }.to change(itinerary.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に追加されている場合、失敗すること" do
        create(:itinerary_place, place_id: user_place.place_id, placeable: itinerary)
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "行きたい場所リストに追加"

            expect(page).to have_content "既に追加されています"
          end
        }.not_to change(itinerary.places, :count)
      end

      it "上限の300件まで登録済みの場合、失敗すること" do
        create_list(:itinerary_place, 300, placeable: itinerary)
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "行きたい場所リストに追加"

            expect(page).to have_content "スポットの登録数が上限に達しています"
          end
        }.not_to change(itinerary.places, :count)
      end
    end
  end

  describe "行きたい場所リストから削除", js: true do
    let!(:itinerary_place) { create(:itinerary_place, :opera_house, placeable: itinerary) }

    context "スポット検索画面のモーダルから削除する場合" do
      it "成功すること" do
        expect {
          visit new_itinerary_place_path(itinerary_id: itinerary.id,
                                         place_id: itinerary_place.place_id)
          click_on "行きたい場所リストに追加済み", match: :first

          expect(page).to have_selector ".bg-gradient-primary", text: "行きたい場所リストに追加"
        }.to change(itinerary.places, :count).by(-1)
      end
    end

    context "行きたい場所リスト一覧画面から削除する場合" do
      it "成功すること" do
        expect {
          visit itinerary_places_path(itinerary_id: itinerary.id)
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            find("i", text: "close").click
          end

          expect(page).to have_content "このスポットを削除しますか？"

          click_on "削除する"

          expect(page).to have_content "スポットを削除しました。"
          expect(page).not_to have_content "シドニー・オペラハウス"
          expect(current_path).to eq itinerary_places_path(itinerary_id: itinerary.id)
        }.to change(itinerary.places, :count).by(-1)
      end
    end
  end
end
