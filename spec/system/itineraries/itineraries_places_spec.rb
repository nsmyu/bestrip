require 'rails_helper'

RSpec.describe "Itineraries::Places", type: :system, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    let(:itinerary_place) { build(:itinerary_place, :opera_house, placeable: itinerary) }

    context "スポットリストに登録がない場合" do
      it "その旨メッセージを表示すること" do
        visit itinerary_places_path(itinerary_id: itinerary.id)
        expect(page).to have_content "登録されているスポットはありません"
      end
    end

    context "スポットリストに登録がある場合", js: true do
      it "登録されているスポット全ての情報を表示すること" do
        itinerary_place.save
        create(:itinerary_place, :queen_victoria_building, placeable: itinerary)
        visit itinerary_places_path(itinerary_id: itinerary.id)

        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end

      it "place_idが無効な（変更されている）場合、エラーメッセージを表示すること" do
        create(:itinerary_place, place_id: "invalid_place_id", placeable: itinerary)
        visit itinerary_places_path(itinerary_id: itinerary.id)

        expect(page).to have_content "スポット情報を取得できませんでした"
      end

      it "スポットの名称をクリックすると、スポット情報のモーダルを表示すること" do
        itinerary_place.save
        visit itinerary_places_path(itinerary_id: itinerary.id)
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
      visit itinerary_places_find_path(itinerary_id: itinerary.id)
      fill_in "searchbox_text_input", with: "シドニー オペラハウス"
      sleep 0.5
      find("#searchbox_text_input").click
      all("span.pac-matched", text: "シドニー・オペラハウス")[1].click
      find("img[src*='maps.gstatic.com/mapfiles/transparent.png']").hover

      click_on "スポット詳細"

      within ".modal" do
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        expect(page).to have_content "作成中のプランに追加"
      end
    end
  end

  describe "スポットリスト登録", js: true do
    let(:itinerary_place) { build(:itinerary_place, :opera_house, placeable: itinerary) }

    context "追加登録可能な状態の場合" do
      it "成功すること" do
        expect {
          visit new_itinerary_place_path(itinerary_id: itinerary.id, place_id: itinerary_place.place_id)
          find(".bg-gradient-primary", text: "作成中のプランに追加").click

          expect(page).to have_content "作成中のプランに追加済み"
        }.to change(itinerary.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既に登録されている場合、追加済みボタンが表示されること" do
        itinerary_place.save
        visit new_itinerary_place_path(itinerary_id: itinerary.id, place_id: itinerary_place.place_id)

        expect(page).to have_content "作成中のプランに追加済み"
      end

      it "上限の300件まで登録済みの場合、その旨メッセージを表示すること" do
        create_list(:itinerary_place, 300, placeable: itinerary)
        visit new_itinerary_place_path(itinerary_id: itinerary.id, place_id: itinerary_place.place_id)

        expect(page).to have_content "このプランのスポット登録数が上限に達しています。"
      end
    end
  end

  describe "お気に入り一覧からスポットリストへ登録", js: true do
    let!(:user_place) { create(:user_place, :opera_house, placeable: user) }

    context "追加登録可能な状態の場合" do
      it "成功すること（追加登録後、スポットリストへのリンクを表示すること）" do
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "選択した旅のプランに追加"

            expect(page).to have_content "選択したプランのスポットリストに追加しました"

            click_on "スポットリストを確認"
          end

          expect(page).to have_content itinerary.title
          expect(page).to have_content "シドニー・オペラハウス"
          expect(current_path).to eq itinerary_places_path(itinerary_id: itinerary.id)
        }.to change(itinerary.places, :count).by(1)
      end
    end

    context "追加登録不可能な状態の場合" do
      it "既にスポットリストに登録されている場合、失敗すること" do
        create(:itinerary_place, place_id: user_place.place_id, placeable: itinerary)
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "選択した旅のプランに追加"

            expect(page).to have_content "このプランには既に追加されています"
          end
        }.not_to change(itinerary.places, :count)
      end

      it "選択したプランのスポットリストに上限の300件まで登録済みの場合、失敗すること" do
        create_list(:itinerary_place, 300, placeable: itinerary)
        expect {
          visit users_places_path
          within(:xpath, "//div[a[p[contains(text(), 'シドニー・オペラハウス')]]]") do
            click_on "旅のプランに追加"
          end

          within(".modal", match: :first) do
            find(".select-box").click
            find("option", text: itinerary.title).click
            click_on "選択した旅のプランに追加"

            expect(page).to have_content "スポットの登録数が上限に達しています"
          end
        }.not_to change(itinerary.places, :count)
      end
    end
  end

  describe "スポットリストから削除", js: true do
    let!(:itinerary_place) { create(:itinerary_place, :opera_house, placeable: itinerary) }

    context "スポット検索画面のモーダルから削除する場合" do
      it "成功すること" do
        expect {
          visit new_itinerary_place_path(itinerary_id: itinerary.id, place_id: itinerary_place.place_id)
          click_on "作成中のプランに追加済み", match: :first

          expect(page).to have_selector ".bg-gradient-primary", text: "作成中のプランに追加"
        }.to change(itinerary.places, :count).by(-1)
      end
    end

    context "スポットリスト一覧画面から削除する場合" do
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
