require "rails_helper"

RSpec.describe "Schedules", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:schedule) { build(:schedule) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "スケジュールが登録されていない場合" do
      it "メッセージを表示すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(page).to have_content "スケジュールは登録されていません"
      end
    end

    context "スケジュールが登録されている場合" do
      let!(:schedule1) { create(:schedule, itinerary: itinerary) }

      it "スケジュールを日付の昇順で表示すること" do
        schedule2 = create(:schedule, schedule_date: "2024-02-01", itinerary: itinerary)
        schedule3 = create(:schedule, schedule_date: "2024-02-03", itinerary: itinerary)

        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        expect(page.text)
          .to match(/#{schedule2.title}[\s\S]*#{schedule1.title}[\s\S]*#{schedule3.title}/)
      end

      it "同日のスケジュールを開始時間の昇順で表示すること" do
        schedule2 = create(:schedule, start_at: "12:00:00", itinerary: itinerary)
        schedule3 = create(:schedule, start_at: "14:00:00", itinerary: itinerary)

        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule.schedule_date}')]]") do
          expect(page.text)
            .to match(/#{schedule2.title}[\s\S]*#{schedule1.title}[\s\S]*#{schedule3.title}/)
        end
      end

      it "スケジュールのタイトル、アイコン、日付、時間を表示すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)

        within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule1.schedule_date}')]]") do
          expect(page).to have_content schedule1.icon
          expect(page).to have_content schedule1.title
          expect(page).to have_content I18n.l schedule1.start_at
          expect(page).to have_content I18n.l schedule1.end_at
        end
      end

      it "他の旅のプランのスケジュールが表示されていないこと" do
        other_itinerary = create(:itinerary, owner: user)
        other_itinerary_schedule = create(:schedule, itinerary: other_itinerary)
        visit itinerary_schedules_path(itinerary_id: itinerary.id)

        expect(page).not_to have_content other_itinerary_schedule.title
      end
    end

    describe "リンクのテスト" do
      let!(:schedule) { create(:schedule, itinerary: itinerary) }

      it "ドロップダウンメニューの「情報を見る」をクリックすると、スケジュール詳細モーダルを表示すること", js: true do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find(".schedule-dropdown-icon", match: :first).click
        click_on "情報を見る", match: :first

        within(".modal") do
          expect(page).to have_content "スケジュール詳細"
          expect(page).to have_content schedule.title
        end
      end

      it "ドロップダウンメニューの「編集」をクリックすると、スケジュール編集モーダルを表示すること", js: true do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find(".schedule-dropdown-icon", match: :first).click
        click_on "編集", match: :first

        within(".modal") do
          expect(page).to have_content "スケジュール編集"
          expect(page).to have_xpath "//input[@value='#{schedule.title}']"
        end
      end

      it "「スケジュール作成」ボタンをクリックすると、スケジュール編集モーダルを表示すること", js: true do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        click_on "スケジュール作成"

        within(".modal") do
          expect(page).to have_content "スケジュール作成"
        end
      end
    end
  end

  describe "新規作成", js: true do
    before do
      visit new_itinerary_schedule_path(itinerary_id: itinerary.id)
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          fill_in "schedule[title]", with: schedule.title
          page.execute_script "schedule_date.value = '#{schedule.schedule_date}'"
          page.execute_script "schedule_start_at.value = '#{schedule.start_at}'"
          page.execute_script "schedule_end_at.value = '#{schedule.end_at}'"
          find("i", text: "#{schedule.icon}").click
          fill_in "schedule[note]", with: schedule.note
          click_on "保存する"

          expect(page).to have_content "新しいスケジュールを作成しました。"
          within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule.schedule_date}')]]") do
            expect(page).to have_content schedule.title
            expect(page).to have_content schedule.icon
            expect(page).to have_content I18n.l schedule.start_at
            expect(page).to have_content I18n.l schedule.end_at
          end
          expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)

          find(".schedule-dropdown-icon", match: :first).click
          click_on "情報を見る", match: :first

          expect(page).to have_content schedule.note
        }.to change(Schedule, :count).by(1)
      end

      it "スポット情報を追加できること" do
        fill_in "schedule[title]", with: schedule.title
        fill_in "autocomplete_text_input", with: "シドニー オペラハウス"
        sleep 0.5
        find("#autocomplete_text_input").click
        find("span.pac-matched", text: "シドニー・オペラハウス", match: :first).click

        within("div#place_info_card") do
          expect(page).to have_content "Sydney Opera House"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000, Australia"
          expect(page)
            .to have_selector "img[src*='maps.googleapis.com/maps/api/place/js/PhotoService']"
          expect(page).to have_selector "iframe[src$='place_id:#{schedule.place_id}']"
        end

        find("i", text: "close").click

        expect(page).not_to have_selector "#place_info_card"
        expect(page).to have_selector "#empty_place_info_card"

        fill_in "autocomplete_text_input", with: "クイーンビクトリアビルディング"
        sleep 0.5
        find("#autocomplete_text_input").click
        find("span.pac-matched", text: "クイーン・ビクトリア・ビルディング", match: :first).click

        within("div#place_info_card") do
          expect(page).to have_content "Queen Victoria Building"
          expect(page).to have_content "455 George St, Sydney NSW 2000, Australia"
          expect(page)
            .to have_selector "img[src*='maps.googleapis.com/maps/api/place/js/PhotoService']"
        end

        click_on "保存する"
        find(".schedule-dropdown-icon", match: :first).click
        click_on "情報を見る", match: :first

        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        expect {
          fill_in "schedule[title]", with: ""
          click_on "保存する"

          expect(page).to have_content "タイトルを入力してください"
        }.not_to change(Schedule, :count)
      end

      it "タイトルが51文字以上の場合、失敗すること" do
        expect {
          fill_in "schedule[title]", with: "a" * 51
          click_on "保存する"

          expect(page).to have_content "タイトルは50文字以内で入力してください"
        }.not_to change(Schedule, :count)
      end

      it "メモが501文字以上入力された場合、「保存する」ボタンが押せないこと" do
        fill_in "schedule[note]", with: "a" * 500

        expect(page).to have_content "500"
        expect(find("#submit_btn", visible: false)).not_to be_disabled

        fill_in "schedule[note]", with: "a" * 501

        expect(page).to have_content "501"
        expect(find("#submit_btn", visible: false)).to be_disabled
      end
    end

    describe "日付入力のflatpickr" do
      it "出発日〜帰宅日の間の日付のみ選択可能であること" do
        find("#schedule_date", visible: false).sibling("input").click
        find("span[aria-label='2月 1, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        sleep 0.5

        find("#schedule_date", visible: false).sibling("input").click
        find("span[aria-label='2月 8, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        find("#schedule_date", visible: false).sibling("input").click
        within("div.flatpickr-calendar") do
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='1月 31, 2024']"
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='2月 9, 2024']"
        end
      end
    end
  end

  describe "詳細表示", js: true do
    context "有効な値の場合" do
      let!(:schedule) { create(:schedule, itinerary: itinerary) }

      before do
        visit itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
      end

      it "スケジュールのタイトル、アイコン、日付、時間、メモを表示すること" do
        expect(page).to have_content schedule.title
        expect(page).to have_content schedule.icon
        expect(page).to have_content I18n.l schedule.schedule_date
        expect(page).to have_content I18n.l schedule.start_at
        expect(page).to have_content I18n.l schedule.end_at
        expect(page).to have_content schedule.note
      end

      it "スケジュールのスポット情報を表示すること" do
        expect(page).to have_content "シドニー・オペラハウス"
        expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
        expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
        expect(page).to have_selector "iframe[src$='place_id:#{schedule.place_id}']"
      end
    end

    context "無効な値の場合" do
      it "place_idが間違っている(変更されている)場合、エラーメッセージを表示すること" do
        schedule = create(:schedule, place_id: "invalid_place_id", itinerary: itinerary)
        visit itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
        expect(page).to have_content "スポット情報を取得できませんでした"
      end
    end
  end

  describe "編集", js: true do
    let!(:schedule) { create(:schedule, itinerary: itinerary) }

    before do
      visit edit_itinerary_schedule_path(itinerary_id: itinerary.id, id: schedule.id)
    end

    context "有効な値の場合" do
      it "成功すること(スポット情報以外)" do
        fill_in "schedule[title]", with: "New title"
        page.execute_script "schedule_date.value = '2024-02-03'"
        page.execute_script "schedule_start_at.value = '14:00:00'"
        page.execute_script "schedule_end_at.value = '16:00:00'"
        find("i", text: "shopping_cart").click
        fill_in "schedule[note]", with: "New note"
        click_on "保存する"

        expect(page).to have_content "スケジュール情報を変更しました。"
        within(:xpath, "//div[h5[contains(text(), '2024/2/3')]]") do
          expect(page).to have_content "New title"
          expect(page).to have_content "shopping_cart"
          expect(page).to have_content '14:00'
          expect(page).to have_content '16:00'
        end
        expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)

        find(".schedule-dropdown-icon", match: :first).click
        click_on "情報を見る", match: :first

        expect(page).to have_content "New note"
      end

      it "スポット情報を変更できること" do
        fill_in "autocomplete_text_input", with: "クイーンビクトリアビルディング"
        sleep 0.5
        find("#autocomplete_text_input").click
        find("span.pac-matched", text: "クイーン・ビクトリア・ビルディング", match: :first).click

        within("div#place_info_card") do
          expect(page).to have_content "Queen Victoria Building"
          expect(page).to have_content "455 George St, Sydney NSW 2000, Australia"
          expect(page)
            .to have_selector "img[src*='maps.googleapis.com/maps/api/place/js/PhotoService']"
          expect(page).to have_selector "iframe[src$='place_id:ChIJISz8NjyuEmsRFTQ9Iw7Ear8']"
        end

        click_on "保存する"
        find(".schedule-dropdown-icon", match: :first).click
        click_on "情報を見る", match: :first

        expect(page).to have_content "クイーン・ビクトリア・ビルディング"
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        fill_in "schedule[title]", with: ""
        click_on "保存する"

        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが51文字以上の場合、失敗すること" do
        fill_in "schedule[title]", with: "a" * 51
        click_on "保存する"

        expect(page).to have_content "タイトルは50文字以内で入力してください"
      end

      it "メモが501文字以上入力された場合、「保存する」ボタンが押せないこと" do
        fill_in "schedule[note]", with: "a" * 500

        expect(page).to have_content "500"
        expect(find("#submit_btn", visible: false)).not_to be_disabled

        fill_in "schedule[note]", with: "a" * 501

        expect(page).to have_content "501"
        expect(find("#submit_btn", visible: false)).to be_disabled
      end
    end

    describe "日付入力のflatpickr" do
      it "出発日〜帰宅日の間の日付のみ選択可能であること" do
        find("#schedule_date", visible: false).sibling("input").click
        find("span[aria-label='2月 1, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        sleep 0.5

        find("#schedule_date", visible: false).sibling("input").click
        find("span[aria-label='2月 8, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        find("#schedule_date", visible: false).sibling("input").click
        within("div.flatpickr-calendar") do
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='1月 31, 2024']"
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='2月 9, 2024']"
        end
      end
    end
  end

  describe "削除", js: true do
    let!(:schedule) { create(:schedule, itinerary: itinerary) }

    it "成功すること" do
      expect {
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find(".schedule-dropdown-icon", match: :first).click
        click_on "削除", match: :first

        expect(page).to have_content "このスケジュールを削除しますか？この操作は取り消せません。"

        click_on "削除する"

        expect(page).to have_content "#{schedule.title}を削除しました。"
        expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)
      }.to change(Schedule, :count).by(-1)
    end
  end
end
