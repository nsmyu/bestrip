require "rails_helper"

RSpec.describe "Schedules", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:itinerary1) { create(:itinerary, owner: user) }
  let!(:itinerary2) { create(:itinerary, owner: user) }
  let(:schedule) { build(:schedule) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "スケジュールが登録されていない場合" do
      it "メッセージを表示すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        expect(page).to have_content "スケジュールは登録されていません"
      end
    end

    context "スケジュールが複数登録されている場合" do
      let!(:schedule1) { create(:schedule, itinerary: itinerary1) }

      it "スケジュールを日付の昇順で表示すること" do
        schedule2 = create(:schedule, schedule_date: "2024-02-01", itinerary: itinerary1)
        schedule3 = create(:schedule, schedule_date: "2024-02-03", itinerary: itinerary1)

        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        expect(page.text)
          .to match(/#{schedule2.title}[\s\S]*#{schedule1.title}[\s\S]*#{schedule3.title}/)
      end

      it "同日のスケジュールを開始時間の昇順で表示すること" do
        schedule2 = create(:schedule, start_at: "12:00:00", itinerary: itinerary1)
        schedule3 = create(:schedule, start_at: "14:00:00", itinerary: itinerary1)

        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule1.schedule_date}')]]") do
          expect(page.text)
            .to match(/#{schedule2.title}[\s\S]*#{schedule1.title}[\s\S]*#{schedule3.title}/)
        end
      end

      it "スケジュールの日付、開始・終了時間、タイトル、アイコンを表示すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule1.schedule_date}')]]") do
          expect(page).to have_content schedule1.icon
          expect(page).to have_content schedule1.title
          expect(page).to have_content I18n.l schedule1.start_at
          expect(page).to have_content I18n.l schedule1.end_at
        end
      end

      it "他の旅のプランのスケジュールが表示されていないこと" do
        other_itinerary_schedule = create(:schedule, itinerary: itinerary2)
        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        expect(page).not_to have_content other_itinerary_schedule.title
      end

      it "スケジュールをクリックすると、スケジュール詳細ページへ遷移すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        click_on schedule1.title
        expect(current_path)
          .to eq itinerary_schedule_path(id: schedule1.id, itinerary_id: itinerary1.id)
      end

      it "「スケジュール作成」ボタンをクリックすると、スケジュール作成ページへ遷移すること" do
        visit itinerary_schedules_path(itinerary_id: itinerary1.id)
        click_on "スケジュール作成"
        expect(current_path)
          .to eq new_itinerary_schedule_path(itinerary_id: itinerary1.id)
      end
    end
  end

  describe "新規作成", js: true, focus: true  do
    before do
      visit new_itinerary_schedule_path(itinerary_id: itinerary1.id)
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          fill_in "schedule[title]", with: schedule.title
          page.execute_script "schedule_date.value = '#{schedule.schedule_date}'"
          page.execute_script "schedule_start_at.value = '#{I18n.l schedule.start_at}'"
          page.execute_script "schedule_end_at.value = '#{I18n.l schedule.end_at}'"

          find("i", text: "attraction").click
          click_on "保存する"

          expect(page).to have_content "新しいスケジュールを作成しました。"
          within(:xpath, "//div[h5[contains(text(), '#{I18n.l schedule.schedule_date}')]]") do
            expect(page).to have_content schedule.title
            expect(page).to have_content I18n.l schedule.start_at
            expect(page).to have_content I18n.l schedule.end_at
            expect(page).to have_content schedule.icon
          end
          expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary1.id)
        }.to change(Schedule, :count).by(1)
      end

      it "スポット情報を追加できること" do
        fill_in "schedule[title]", with: schedule.title
        fill_in "query_input", with: "Sydney opera house"
        sleep 0.2
        find("#query_input").click
        find("span.pac-matched", text: "Sydney Opera House", match: :first).click

        within("div#place_info_card") do
          expect(page).to have_content "Sydney Opera House"
          expect(page).to have_content "Bennelong Point, Sydney NSW 2000, Australia"
          expect(page)
            .to have_selector "img[src*='maps.googleapis.com/maps/api/place/js/PhotoService']"
        end

        find("i", text: "close").click

        expect(page).not_to have_selector "#place_info_card"
        expect(page).to have_selector "#place_info_empty"

        fill_in "query_input", with: "Sydney Harbour Bridge"
        sleep 0.2
        find("#query_input").click
        find("span.pac-matched", text: "Sydney Harbour Bridge", match: :first).click

        within("div#place_info_card") do
          expect(page).to have_content "Sydney Harbour Bridge"
          expect(page).to have_content "Sydney Hbr Brg, Sydney NSW, Australia"
          expect(page)
            .to have_selector "img[src*='maps.googleapis.com/maps/api/place/js/PhotoService']"
        end

        click_on "保存する"
        # visit  itinerary_schedule_path(id: )
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
    end

    describe "日付入力のflatpickr" do
      it "出発日〜帰宅日の間の日付のみ選択可能であること" do
        find("#schedule_date").click
        find("span[aria-label='2月 1, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        find("#schedule_date").click
        find("span[aria-label='2月 8, 2024']").click
        expect(page).not_to have_selector ".flatpickr-calendar.open"

        find("#schedule_date").click
        within("div.flatpickr-calendar") do
          expect(page).to have_content "2月"
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='1月 31, 2024']"
          expect(page).to have_selector "span.flatpickr-disabled[aria-label='2月 9, 2024']"
        end
      end
    end
  end

  # describe "詳細表示" do
  #   let!(:itinerary) { create(:itinerary, owner: user) }

  #   before do
  #     itinerary.members << other_user
  #     visit itinerary_path(itinerary.id)
  #   end

  #   it "旅のタイトル、出発・帰宅日、メンバーのニックネームを表示すること" do
  #     expect(page).to have_content itinerary.title
  #     expect(page).to have_content itinerary.departure_date.strftime('%Y/%-m/%-d')
  #     expect(page).to have_content itinerary.return_date.strftime('%Y/%-m/%-d')
  #     expect(page).to have_content user.name
  #     expect(page).to have_content other_user.name
  #   end
  # end

  # describe "編集", js: true do
  #   let!(:itinerary1) { create(:itinerary, owner: user) }
  #   let!(:itinerary2) { create(:itinerary, owner: user) }

  #   before do
  #     visit itinerary_path(itinerary1.id)
  #     find("i", text: "edit").click
  #   end

  #   context "有効な値の場合" do
  #     it "成功すること" do
  #       fill_in "itinerary[title]", with: "New Title"
  #       fill_in "itinerary[departure_date]", with: "Mon Apr 01 2024 00:00:00 GMT+0900"
  #       fill_in "itinerary[return_date]", with: "Mon Apr 08 2024 00:00:00 GMT+0900"

  #       expect(page).to have_selector "img[id='image_preview'][src*='default_itinerary']"

  #       image_path = Rails.root.join('spec/fixtures/test_image.jpg')
  #       attach_file 'itinerary[image]', image_path, make_visible: true

  #       expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"

  #       click_on "保存する"

  #       expect(current_path).to eq itinerary_path(itinerary1.id)
  #       expect(page).to have_content "旅のプラン情報を変更しました。"
  #       expect(page).to have_content "New Title"
  #       expect(page).to have_content "2024/4/1 (月) 〜 2024/4/8 (月)"
  #       expect(page).to have_selector "img[src*='test_image.jpg']"
  #     end
  #   end

  #   context "無効な値の場合" do
  #     it "タイトルが空欄の場合、失敗すること" do
  #       fill_in "itinerary[title]", with: ""
  #       click_on "保存する"
  #       expect(page).to have_content "タイトルを入力してください"
  #     end

  #     it "タイトルが同じユーザーで重複している場合、失敗すること" do
  #       fill_in "itinerary[title]", with: itinerary2.title
  #       click_on "保存する"
  #       expect(page).to have_content "このタイトルはすでに使用されています"
  #     end

  #     it "タイトルが31文字以上の場合、失敗すること" do
  #       fill_in "itinerary[title]", with: "a" * 31
  #       click_on "保存する"
  #       expect(page).to have_content "タイトルは30文字以内で入力してください"
  #     end

  #     it "出発日より前の日付は帰宅日として選択できないこと" do
  #       find("#departure-date").click
  #       find('div.dayContainer > span:nth-child(2)').click
  #       sleep 0.1
  #       find("#return-date").click
  #       expect(page)
  #         .to have_selector "div.dayContainer > span:nth-child(1)", class: "flatpickr-disabled"
  #     end
  #   end
  # end

  # describe "削除", js: true do
  #   let!(:itinerary) { create(:itinerary, owner: user) }

  #   before do
  #     itinerary.members << other_user
  #   end

  #   it "成功すること" do
  #     expect {
  #       visit itinerary_path(itinerary.id)
  #       find("i", text: "delete").click
  #       click_on "削除する"
  #       expect(page).to have_content "#{itinerary.title}を削除しました。"
  #       expect(current_path).to eq itineraries_path
  #     }.to change(Itinerary, :count).by(-1)
  #   end

  #   it "作成者以外は削除できない（削除ボタンが表示されない）こと" do
  #     sign_out user
  #     sign_in other_user
  #     visit itinerary_path(itinerary.id)
  #     expect(page).not_to have_selector "i", text: "delete"
  #   end
  # end
end
