require "rails_helper"

RSpec.describe "Schedules", type: :system do
  shared_examples "旅のメンバー共通機能" do |user_type|
    before do
      set_signed_in_user(user_type)
    end

    describe "一覧表示" do
      context "スケジュールが登録されていない場合" do
        it "メッセージを表示すること" do
          visit itinerary_schedules_path(itinerary_id: itinerary.id)
          expect(page).to have_content "スケジュールは登録されていません"
        end
      end

      context "スケジュールが登録されている場合" do
        let!(:schedule) { create(:schedule, itinerary: itinerary) }

        it "スケジュールを日付の昇順で表示すること" do
          sched_day3 = create(:schedule, date: "2024-02-03", itinerary: itinerary)
          sched_day2 = create(:schedule, itinerary: itinerary)
          sched_day1 = create(:schedule, date: "2024-02-01", itinerary: itinerary)

          visit itinerary_schedules_path(itinerary_id: itinerary.id)

          expect(page.text)
            .to match(/#{sched_day1.title}[\s\S]*#{sched_day2.title}[\s\S]*#{sched_day3.title}/)
        end

        it "同日のスケジュールを開始時間の昇順で表示すること" do
          sched_1pm = create(:schedule, itinerary: itinerary)
          sched_2pm = create(:schedule, start_at: "14:00:00", itinerary: itinerary)
          sched_10am = create(:schedule, start_at: "10:00:00", itinerary: itinerary)

          visit itinerary_schedules_path(itinerary_id: itinerary.id)

          within(:xpath, "//div[p[contains(text(), '#{I18n.l schedule.date}')]]") do
            expect(page.text)
              .to match(/#{sched_10am.title}[\s\S]*#{sched_1pm.title}[\s\S]*#{sched_2pm.title}/)
          end
        end

        it "スケジュールの日付、時間、アイコン、タイトルを表示すること" do
          visit itinerary_schedules_path(itinerary_id: itinerary.id)

          within(:xpath, "//div[p[contains(text(), '#{I18n.l schedule.date}')]]") do
            expect(page).to have_content I18n.l schedule.start_at
            expect(page).to have_content I18n.l schedule.end_at
            expect(page).to have_content schedule.icon
            expect(page).to have_content schedule.title
          end
        end

        it "ドロップダウンメニューの「スケジュール詳細」をクリックすると、スケジュール詳細モーダルを表示すること", js: true do
          visit itinerary_schedules_path(itinerary_id: itinerary.id)
          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "スケジュール詳細", match: :first

          within(".modal") do
            expect(page).to have_content "スケジュール詳細"
            expect(page).to have_content schedule.title
          end
        end

        it "ドロップダウンメニューの「編集」をクリックすると、スケジュール編集モーダルを表示すること", js: true do
          visit itinerary_schedules_path(itinerary_id: itinerary.id)
          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "編集", match: :first

          within(".modal") do
            expect(page).to have_content "スケジュール編集"
            expect(page).to have_field 'schedule[title]', with: schedule.title
          end
        end

        it "「スケジュールを追加」をクリックすると、スケジュール作成モーダルを表示すること", js: true do
          visit itinerary_schedules_path(itinerary_id: itinerary.id)
          click_on "スケジュールを追加"

          within(".modal") do
            expect(page).to have_content "スケジュール作成"
          end
        end
      end
    end

    describe "新規作成", js: true do
      let(:schedule) { build(:schedule) }

      before do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        click_on "スケジュールを追加"
      end

      context "有効な値の場合" do
        it "成功すること" do
          expect {
            fill_in "schedule[title]", with: schedule.title
            page.execute_script "schedule_date.value = '#{schedule.date}'"
            page.execute_script "schedule_start_at.value = '#{schedule.start_at}'"
            page.execute_script "schedule_end_at.value = '#{schedule.end_at}'"
            find("i", text: "#{schedule.icon}").click
            fill_in "schedule[note]", with: schedule.note
            click_on "保存する"

            expect(page).to have_content "新しいスケジュールを作成しました。"
            within(:xpath, "//div[p[contains(text(), '#{I18n.l schedule.date}')]]") do
              expect(page).to have_content schedule.title
              expect(page).to have_content schedule.icon
              expect(page).to have_content I18n.l schedule.start_at
              expect(page).to have_content I18n.l schedule.end_at
            end
            expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)

            find("i", text: "more_vert", match: :first).click
            click_on "スケジュール詳細", match: :first

            within(".modal") do
              expect(page).to have_content schedule.note
            end
          }.to change(Schedule, :count).by(1)
        end

        it "スポット情報を追加できること（スポット情報のプレビューを表示すること）" do
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

          click_on "保存する"
          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "スケジュール詳細"

          within(".modal") do
            expect(page).to have_content "シドニー・オペラハウス"
          end
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

        it "メモが501文字以上入力されると「保存する」ボタンが無効化されること" do
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
          fill_in "schedule[title]", with: schedule.title
          find("#schedule_date", visible: false).sibling("input").click
          find("span[aria-label='2月 1, 2024']").click
          click_on "保存する"

          expect(page).to have_content "新しいスケジュールを作成しました。"

          click_on "スケジュールを追加"
          fill_in "schedule[title]", with: schedule.title
          find("#schedule_date", visible: false).sibling("input").click
          find("span[aria-label='2月 8, 2024']").click
          click_on "保存する"

          expect(page).to have_content "新しいスケジュールを作成しました。"

          click_on "スケジュールを追加"
          find("#schedule_date", visible: false).sibling("input").click
          within("div.flatpickr-calendar") do
            expect(find("span[aria-label='1月 31, 2024']")).to match_css(".flatpickr-disabled")
            expect(find("span[aria-label='2月 9, 2024']")).to match_css(".flatpickr-disabled")
          end
        end
      end
    end

    describe "詳細表示", js: true do
      let!(:schedule) { create(:schedule, itinerary: itinerary) }

      before do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find("i", text: "more_vert", visible: false, match: :first).click
        click_on "スケジュール詳細", match: :first
      end

      it "スケジュールのタイトル、アイコン、日付、時間、メモを表示すること" do
        within(".modal") do
          expect(page).to have_content "スケジュール詳細"
          expect(page).to have_content schedule.title
          expect(page).to have_content schedule.icon
          expect(page).to have_content I18n.l schedule.date
          expect(page).to have_content I18n.l schedule.start_at
          expect(page).to have_content I18n.l schedule.end_at
          expect(page).to have_content schedule.note
        end
      end

      it "スケジュールのスポット情報を表示すること" do
        within(".modal") do
          expect(page).to have_content "シドニー・オペラハウス"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
          expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
          expect(page).to have_selector "iframe[src$='place_id:#{schedule.place_id}']"
        end
      end

      it "place_idが無効な場合、エラーメッセージを表示すること" do
        schedule.update(place_id: "invalid_place_id")
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find("i", text: "more_vert", visible: false, match: :first).click
        click_on "スケジュール詳細", match: :first

        expect(page).to have_content "スポット情報を取得できませんでした"
      end
    end

    describe "編集", js: true do
      let!(:schedule) { create(:schedule, itinerary: itinerary) }

      before do
        visit itinerary_schedules_path(itinerary_id: itinerary.id)
        find("i", text: "more_vert", visible: false, match: :first).click
        click_on "編集", match: :first
      end

      context "有効な値の場合" do
        it "成功すること(スポット情報以外)" do
          fill_in "schedule[title]", with: "Edited title"
          page.execute_script "schedule_date.value = '2024-02-03'"
          page.execute_script "schedule_start_at.value = '14:00:00'"
          page.execute_script "schedule_end_at.value = '16:00:00'"
          find("i", text: "shopping_cart").click
          fill_in "schedule[note]", with: "Edited note"
          click_on "保存する"

          expect(page).to have_content "スケジュール情報を変更しました。"
          within(:xpath, "//div[p[contains(text(), '2024/2/3')]]") do
            expect(page).to have_content "Edited title"
            expect(page).to have_content "shopping_cart"
            expect(page).to have_content '14:00'
            expect(page).to have_content '16:00'
          end
          expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)

          find("i", text: "more_vert", match: :first).click
          click_on "スケジュール詳細", match: :first

          expect(page).to have_content "Edited note"
        end

        it "スポット情報を変更できること" do
          within("div#place_info_card") do
            expect(page).to have_content "シドニー・オペラハウス"
            expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
            expect(page)
              .to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
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
          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "スケジュール詳細"

          expect(page).to have_content "クイーン・ビクトリア・ビルディング"
        end
      end

      context "無効な値の場合" do
        it "タイトルが空欄の場合、失敗すること" do
          fill_in "schedule[title]", with: ""
          click_on "保存する"

          expect(page).to have_content "タイトルを入力してください"
          expect(schedule.reload.title).to eq schedule.title
        end

        it "タイトルが51文字以上の場合、失敗すること" do
          fill_in "schedule[title]", with: "a" * 51
          click_on "保存する"

          expect(page).to have_content "タイトルは50文字以内で入力してください"
          expect(schedule.reload.title).to eq schedule.title
        end

        it "メモが501文字以上入力されると「保存する」ボタンが無効化されること" do
          fill_in "schedule[note]", with: "a" * 500

          expect(page).to have_content "500"
          expect(find("#submit_btn")).not_to be_disabled

          fill_in "schedule[note]", with: "a" * 501

          expect(page).to have_content "501"
          expect(find("#submit_btn")).to be_disabled
        end
      end

      describe "日付入力のflatpickr" do
        it "出発日〜帰宅日の間の日付のみ選択可能であること" do
          find("#schedule_date", visible: false).sibling("input").click
          find("span[aria-label='2月 1, 2024']").click
          click_on "保存する"

          expect(page).to have_content "スケジュール情報を変更しました。"

          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "編集", match: :first
          find("#schedule_date", visible: false).sibling("input").click
          find("span[aria-label='2月 8, 2024']").click
          click_on "保存する"

          expect(page).to have_content "スケジュール情報を変更しました。"

          find("i", text: "more_vert", visible: false, match: :first).click
          click_on "編集", match: :first
          find("#schedule_date", visible: false).sibling("input").click
          within("div.flatpickr-calendar") do
            expect(find("span[aria-label='1月 31, 2024']")).to match_css(".flatpickr-disabled")
            expect(find("span[aria-label='2月 9, 2024']")).to match_css(".flatpickr-disabled")
          end
        end
      end
    end

    describe "削除", js: true do
      let!(:schedule) { create(:schedule, itinerary: itinerary) }

      it "成功すること" do
        expect {
          visit itinerary_schedules_path(itinerary_id: itinerary.id)
          find("i", text: "more_vert", match: :first).click
          click_on "削除", match: :first

          expect(page).to have_content "このスケジュールを削除しますか？"

          click_on "削除する"

          expect(page).to have_content "スケジュールを削除しました。"
          expect(page).not_to have_content schedule.title
          expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)
        }.to change(Schedule, :count).by(-1)
      end
    end
  end

  context "ログインユーザーがプラン作成者の場合" do
    let(:user) { create(:user) }
    let(:itinerary) { create(:itinerary, owner: user) }
    it_behaves_like "旅のメンバー共通機能", :owner
  end

  context "ログインユーザーがプランの作成者以外のメンバーの場合" do
    let(:user) { create(:user) }
    let(:itinerary) { create(:itinerary) }
    it_behaves_like "旅のメンバー共通機能", :member
  end
end
