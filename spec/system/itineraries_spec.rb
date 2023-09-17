require "rails_helper"

RSpec.describe "Itineraries", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, bestrip_id: "other_user_id") }

  before do
    sign_in user
  end

  describe "一覧表示" do
    context "旅のプランが登録されていない場合" do
      it "メッセージを表示すること" do
        visit itineraries_path
        expect(page).to have_content "旅のプランは登録されていません"
      end
    end

    context "旅のプランが複数登録されている場合" do
      let!(:itinerary1) { create(:itinerary, owner: user) }
      let!(:itinerary2) { create(:itinerary, departure_date: "2024-01-31", owner: user) }
      let!(:other_users_itinerary) {
        create(:itinerary, departure_date: "2024-02-02", owner: other_user)
      }

      it "ログインユーザーの全ての旅のプランを、出発日の降順で表示すること" do
        other_users_itinerary.members << user
        visit itineraries_path

        expect(page.text)
          .to match(
            /#{other_users_itinerary.title}[\s\S]*#{itinerary1.title}[\s\S]*#{itinerary2.title}/
          )
      end

      it "旅のタイトル、出発・帰宅日、メンバーのニックネームを表示すること" do
        itinerary1.members << other_user
        visit itineraries_path

        within(:xpath, "//a[@href='/itineraries/#{itinerary1.id}/schedules']") do
          expect(page).to have_content itinerary1.title
          expect(page).to have_content I18n.l itinerary1.departure_date
          expect(page).to have_content I18n.l itinerary1.return_date
          expect(page).to have_content user.name
          expect(page).to have_content other_user.name
        end
      end

      it "他のユーザーの旅のプランが表示されていないこと" do
        visit itineraries_path

        expect(page).not_to have_content other_users_itinerary.title
      end

      it "旅のプランのカードをクリックすると、スケジュール一覧ページへ遷移すること" do
        visit itineraries_path
        click_on itinerary1.title

        expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary1.id)
      end

      it "「旅のプランを作成」ボタンをクリックすると、プラン作成モーダルを表示すること", js: true do
        visit itineraries_path
        click_on "旅のプランを作成"

        within(".modal") do
          expect(page).to have_content "旅のプラン新規作成"
        end
      end
    end
  end

  describe "新規作成", js: true do
    let(:itinerary) { build(:itinerary, owner: user) }

    before do
      visit new_itinerary_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          fill_in "itinerary[title]", with: itinerary.title
          page.execute_script "departure_date.value = '#{itinerary.departure_date}'"
          page.execute_script "return_date.value = '#{itinerary.return_date}'"

          expect(page).to have_selector "img[id='image_preview'][src*='default_itinerary']"

          image_path = Rails.root.join('spec/fixtures/test_image.jpg')
          attach_file 'itinerary[image]', image_path, make_visible: true

          expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"

          click_on "保存する"

          expect(page).to have_content "新しい旅のプランを作成しました。"
          expect(page).to have_content "旅のプラン情報"
          expect(page).to have_content itinerary.title
          expect(page).to have_content I18n.l itinerary.departure_date
          expect(page).to have_content I18n.l itinerary.return_date
          expect(page).to have_content user.name
        }.to change(Itinerary, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: ""
          page.execute_script "departure_date.value = '#{itinerary.departure_date}'"
          page.execute_script "return_date.value = '#{itinerary.return_date}'"
          click_on "保存する"

          expect(page).to have_content "タイトルを入力してください"
        }.not_to change(Itinerary, :count)
      end

      it "出発日と帰宅日が未入力の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: itinerary.title
          click_on "保存する"

          expect(page).to have_content "出発日を入力してください"
          expect(page).to have_content "帰宅日を入力してください"
        }.not_to change(Itinerary, :count)
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: "a" * 31
          page.execute_script "departure_date.value = '#{itinerary.departure_date}'"
          page.execute_script "return_date.value = '#{itinerary.return_date}'"
          click_on "保存する"

          expect(page).to have_content "タイトルは30文字以内で入力してください"
        }.not_to change(Itinerary, :count)
      end

      it "タイトルが同じユーザーで重複している場合、失敗すること" do
        existing_itinerary = create(:itinerary, owner: user)
        expect {
          fill_in "itinerary[title]", with: existing_itinerary.title
          page.execute_script "departure_date.value = '#{itinerary.departure_date}'"
          page.execute_script "return_date.value = '#{itinerary.return_date}'"
          click_on "保存する"

          expect(page).to have_content "このタイトルはすでに使用されています"
        }.not_to change(Itinerary, :count)
      end
    end

    describe "出発日・帰宅日入力のflatpickr" do
      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure_date", visible: false).sibling("input").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.3
        find("#return_date", visible: false).sibling("input").click
        find("div.dayContainer")

        expect(page)
          .to have_selector "div.dayContainer > span:nth-child(1)", class: "flatpickr-disabled"
      end
    end
  end

  describe "詳細表示" do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << other_user
      visit itinerary_path(itinerary.id)
    end

    it "旅のタイトル、出発・帰宅日、メンバーのニックネームを表示すること" do
      expect(page).to have_content itinerary.title
      expect(page).to have_content I18n.l itinerary.departure_date
      expect(page).to have_content I18n.l itinerary.return_date
      expect(page).to have_content user.name
      expect(page).to have_content other_user.name
    end

    it "鉛筆アイコンをクリックすると、プラン編集モーダルを表示すること", js: true do
      find("i", text: "edit").click

      within(".modal") do
        expect(page).to have_content "旅のプラン情報編集"
        expect(page).to have_xpath "//input[@value='#{itinerary.title}']"
      end
    end
  end

  describe "編集", js: true do
    let!(:itinerary1) { create(:itinerary, owner: user) }
    let!(:itinerary2) { create(:itinerary, owner: user) }

    before do
      visit itinerary_path(itinerary1.id)
      find("i", text: "edit").click
    end

    context "有効な値の場合" do
      it "成功すること" do
        fill_in "itinerary[title]", with: "New Title"
        page.execute_script "departure_date.value = '2024-04-01'"
        page.execute_script "return_date.value = '2024-04-08'"

        expect(page).to have_selector "img[id='image_preview'][src*='default_itinerary']"

        image_path = Rails.root.join('spec/fixtures/test_image.jpg')
        attach_file 'itinerary[image]', image_path, make_visible: true

        expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"

        click_on "保存する"

        expect(current_path).to eq itinerary_path(itinerary1.id)
        expect(page).to have_content "旅のプラン情報を変更しました。"
        expect(page).to have_content "New Title"
        expect(page).to have_content "2024/4/1 (月) 〜 2024/4/8 (月)"
        expect(page).to have_selector "img[src*='test_image.jpg']"
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        fill_in "itinerary[title]", with: ""
        click_on "保存する"

        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが同じユーザーで重複している場合、失敗すること" do
        fill_in "itinerary[title]", with: itinerary2.title
        click_on "保存する"

        expect(page).to have_content "このタイトルはすでに使用されています"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        fill_in "itinerary[title]", with: "a" * 31
        click_on "保存する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
      end
    end

    describe "出発日・帰宅日入力のflatpickr" do
      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure_date", visible: false).sibling("input").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.3
        find("#return_date", visible: false).sibling("input").click
        find("div.dayContainer")

        expect(page)
          .to have_selector "div.dayContainer > span:nth-child(1)", class: "flatpickr-disabled"
      end
    end
  end

  describe "削除", js: true do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << other_user
    end

    it "成功すること", focus: true do
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "delete").click

        expect(page).to have_content "この旅のプランを削除しますか？この操作は取り消せません。"

        click_on "削除する"

        expect(page).to have_content "#{itinerary.title}を削除しました。"
        expect(current_path).to eq itineraries_path
      }.to change(Itinerary, :count).by(-1)
    end

    it "作成者以外は削除できない（削除ボタンが表示されない）こと" do
      sign_out user
      sign_in other_user
      visit itinerary_path(itinerary.id)

      expect(page).not_to have_selector "i", text: "delete"
    end
  end
end
