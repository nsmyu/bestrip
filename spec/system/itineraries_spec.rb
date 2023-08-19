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

      before do
        [itinerary1, itinerary2].each { |i| i.members << user << other_user }
      end

      it "ログインユーザーの全ての旅のプランを、出発日の降順で表示すること" do
        other_users_itinerary.members << user
        visit itineraries_path
        expect(page.text)
          .to match(
            /#{other_users_itinerary.title}[\s\S]*#{itinerary1.title}[\s\S]*#{itinerary2.title}/
          )
      end

      it "旅のタイトル、出発・帰宅日、メンバーのニックネームを表示すること" do
        visit itineraries_path
        expect(page).to have_content itinerary1.title
        expect(page).to have_content itinerary1.departure_date.strftime('%Y/%-m/%-d')
        expect(page).to have_content itinerary1.return_date.strftime('%Y/%-m/%-d')
        expect(page).to have_content user.name
        expect(page).to have_content other_user.name
      end

      it "他のユーザーの旅のプランが表示されていないこと" do
        visit itineraries_path
        expect(page).not_to have_content other_users_itinerary.title
      end

      it "旅のプランのカードをクリックすると、旅のプラン情報ページへ遷移すること" do
        visit itineraries_path
        click_on itinerary1.title
        expect(current_path).to eq itinerary_path(itinerary1.id)
      end
    end
  end

  describe "新規作成", js: true do
    before do
      visit itineraries_path
      click_on "旅のプランを作成"
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          fill_in "itinerary[title]", with: "New Trip"
          fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"

          expect(page).to have_selector "img[id='image-preview'][src*='default_itinerary']"

          image_path = Rails.root.join('spec/fixtures/test_image.jpg')
          attach_file 'itinerary[image]', image_path, make_visible: true

          expect(page).not_to have_selector "img[id='image-preview'][src*='default_itinerary']"

          click_on "保存する"

          # expect(current_path).to eq root_path
          expect(page).to have_content "新しい旅のプランを作成しました。次はスケジュールを追加してみましょう。"
          # expect(page).to have_content itinerary.title
          # within ".navbar" do
          #   expect(page).to have_content user.name
          # end
        }.to change(Itinerary, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: ""
          fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          click_on "保存する"
          expect(page).to have_content "タイトルを入力してください"
        }.not_to change(User, :count)
      end

      it "出発日と帰宅日が未入力の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: "New Trip"
          click_on "保存する"
          expect(page).to have_content "出発日を入力してください"
          expect(page).to have_content "帰宅日を入力してください"
        }.not_to change(User, :count)
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: "a" * 31
          fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          click_on "保存する"
          expect(page).to have_content "タイトルは30文字以内で入力してください"
        }.not_to change(User, :count)
      end

      it "タイトルが同じユーザーで重複している場合、失敗すること" do
        existing_itinerary = create(:itinerary, owner: user)
        expect {
          fill_in "itinerary[title]", with: existing_itinerary.title
          fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
          click_on "保存する"
          expect(page).to have_content "このタイトルはすでに使用されています"
        }.not_to change(User, :count)
      end

      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure-date-pickr").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.1
        find("#return-date-pickr").click
        expect(page)
          .to have_selector "div.dayContainer > span:nth-child(1)", class: "flatpickr-disabled"
      end
    end
  end

  describe "編集", js: true, focus: true do
    let!(:itinerary1) { create(:itinerary, owner: user) }
    let!(:itinerary2) { create(:itinerary, owner: user) }

    before do
      itinerary1.members << user
      visit itinerary_path(itinerary1.id)
      find("i", text: "edit").click
    end

    context "有効な値の場合" do
      it "成功すること" do
        fill_in "itinerary[title]", with: "New Title"
        fill_in "itinerary[departure_date]", with: "Mon Apr 01 2024 00:00:00 GMT+0900"
        fill_in "itinerary[return_date]", with: "Mon Apr 08 2024 00:00:00 GMT+0900"

        expect(page).to have_selector "img[id='image-preview'][src*='default_itinerary']"

        image_path = Rails.root.join('spec/fixtures/test_image.jpg')
        attach_file 'itinerary[image]', image_path, make_visible: true

        expect(page).not_to have_selector "img[id='image-preview'][src*='default_itinerary']"

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

      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure-date-pickr").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.1
        find("#return-date-pickr").click
        expect(page)
          .to have_selector "div.dayContainer > span:nth-child(1)", class: "flatpickr-disabled"
      end
    end
  end

  describe "ユーザー検索、メンバー追加", js: true do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << user
      visit itinerary_path(itinerary.id)
      click_on "メンバーを追加"
    end

    it "成功すること" do
      expect {
        fill_in "bestrip_id", with: other_user.bestrip_id
        find("i", text: "search").click

        expect(page).to have_content other_user.name

        click_on "メンバーに追加"

        expect(current_path).to eq itinerary_path(itinerary.id)
        expect(page).to have_content other_user.name
      }.to change(itinerary.members, :count).by(1)
    end

    it "検索したユーザーが存在しない場合、メッセージが表示されること" do
      fill_in "bestrip_id", with: "no_user_id"
      find("i", text: "search").click
      expect(page).to have_content "ユーザーが見つかりませんでした"
    end

    it "検索したユーザーが既にメンバーに含まれている場合、メッセージが表示されること" do
      itinerary.members << other_user
      fill_in "bestrip_id", with: other_user.bestrip_id
      find("i", text: "search").click
      expect(page).to have_content "すでにメンバーに追加されています"
    end
  end

  describe "メンバー削除", js: true do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << user << other_user
    end

    it "成功すること" do
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "person_remove").click
        click_on "削除する"
        expect(current_path).to eq itinerary_path(itinerary.id)
        expect(page).not_to have_content other_user.name
      }.to change(itinerary.members, :count).by(-1)
    end

    it "作成者以外にはメンバー削除ができない（削除ボタンが表示されない）こと" do
      sign_out user
      sign_in other_user
      visit itinerary_path(itinerary.id)
      expect(page).not_to have_selector "i", text: "person_remove"
    end
  end

  describe "削除", js: true do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << user << other_user
    end

    it "成功すること" do
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "delete").click
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
