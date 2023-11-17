require "rails_helper"

RSpec.describe "Itineraries", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, bestrip_id: "other_user_id") }

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
      let!(:itinerary_1) { create(:itinerary, owner: user) }
      let!(:itinerary_2) { create(:itinerary, departure_date: "2024-01-31", owner: user) }
      let!(:other_users_itinerary) {
        create(:itinerary, departure_date: "2024-02-02", owner: other_user)
      }

      it "ログインユーザーの全ての旅のプランを、出発日の降順で表示すること" do
        other_users_itinerary.members << user
        visit itineraries_path

        expect(page.text)
          .to match(
            /#{other_users_itinerary.title}[\s\S]*#{itinerary_1.title}[\s\S]*#{itinerary_2.title}/
          )
      end

      it "旅のタイトル、出発・帰宅日、メンバーのニックネームを表示すること" do
        itinerary_1.members << other_user
        visit itineraries_path

        within(:xpath, "//div[p[contains(text(), '#{itinerary_1.title}')]]") do
          expect(page).to have_content I18n.l itinerary_1.departure_date
          expect(page).to have_content I18n.l itinerary_1.return_date
          expect(page).to have_content user.name
          expect(page).to have_content other_user.name
        end
      end

      it "旅のプランのカードをクリックすると、旅のプラン情報ページへ遷移すること" do
        visit itineraries_path
        click_on itinerary_1.title

        expect(current_path).to eq itinerary_path(id: itinerary_1.id)
      end
    end
  end

  describe "新規作成", js: true do
    let(:itinerary) { build(:itinerary, owner: user) }

    before do
      visit itineraries_path
      find("p", text: "新しいプランを作成").click
    end

    context "有効な値の場合" do
      it "画像プレビューの表示及びプランの作成に成功すること" do
        expect {
          fill_in "itinerary[title]", with: itinerary.title
          page.execute_script "departure_date.value = '#{itinerary.departure_date}'"
          page.execute_script "return_date.value = '#{itinerary.return_date}'"

          expect(page).to have_selector "img[id='image_preview'][src*='default_itinerary']"

          image_path = Rails.root.join('spec/fixtures/cat.jpg')
          attach_file 'itinerary[image]', image_path, make_visible: true

          expect(page).to have_selector "img[id='image_preview'][src*='data:image']"
          expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"

          click_on "保存する"

          expect(page).to have_content "新しい旅のプランを作成しました。"
          expect(page).to have_content itinerary.title
          expect(page).to have_content I18n.l itinerary.departure_date
          expect(page).to have_content I18n.l itinerary.return_date
          expect(page).to have_selector "img[src*='cat.jpg']"
          expect(page).to have_content user.name
          expect(current_path).to eq itinerary_path(id: Itinerary.last.id)
        }.to change(Itinerary, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "必須項目が未入力の場合、失敗すること" do
        expect {
          fill_in "itinerary[title]", with: ""
          click_on "保存する"

          expect(page).to have_content "タイトルを入力してください"
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
    end

    describe "出発日・帰宅日入力のflatpickr" do
      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure_date", visible: false).sibling("input").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.3
        find("#return_date", visible: false).sibling("input").click

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

    context "ログインユーザーがプラン作成者の場合" do
      it "ドロップダウンメニューを表示すること" do
        expect(page).to have_selector "button[id='itinerary_dropdown']"
      end

      it "ドロップダウンメニューの「編集」をクリックすると、投稿編集モーダルを表示すること", js: true do
        find("i", text: "more_horiz", visible: false).click
        click_on "編集"

        within(".modal") do
          expect(page).to have_content "旅のプラン情報編集"
          expect(page).to have_field 'itinerary[title]', with: itinerary.title
        end
      end
      # ドロップダウンメニュー「削除」のリンクについては、後述の削除処理でテストを行う
    end

    context "ログインユーザーがプラン作成者でない場合" do
      it "ドロップダウンメニューを表示しないこと" do
        sign_out user
        sign_in other_user
        visit itinerary_path(itinerary.id)

        expect(page).not_to have_selector "button[id='itinerary_dropdown']"
      end
    end
  end

  describe "編集", js: true do
    let!(:itinerary) { create(:itinerary, owner: user) }

    before do
      visit edit_itinerary_path(itinerary.id)
    end

    context "有効な値の場合" do
      it "画像プレビューの表示及びプランの変更に成功すること" do
        fill_in "itinerary[title]", with: "Edited Title"
        page.execute_script "departure_date.value = '2024-04-01'"
        page.execute_script "return_date.value = '2024-04-08'"

        expect(page).to have_selector "img[id='image_preview'][src*='default_itinerary']"

        image_path = Rails.root.join('spec/fixtures/cat.jpg')
        attach_file 'itinerary[image]', image_path, make_visible: true

        expect(page).to have_selector "img[id='image_preview'][src*='data:image']"
        expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"

        click_on "保存する"

        expect(page).to have_content "旅のプラン情報を変更しました。"
        expect(page).to have_content "Edited Title"
        expect(page).to have_content "2024/4/1 (月) 〜 2024/4/8 (月)"
        expect(page).to have_selector "img[src*='cat.jpg']"
        expect(current_path).to eq itinerary_path(itinerary.id)
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        fill_in "itinerary[title]", with: ""
        click_on "保存する"

        expect(page).to have_content "タイトルを入力してください"
        expect(itinerary.reload.title).to eq itinerary.title
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        fill_in "itinerary[title]", with: "a" * 31
        click_on "保存する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
        expect(itinerary.reload.title).to eq itinerary.title
      end
    end

    describe "出発日・帰宅日入力のflatpickr" do
      it "出発日より前の日付は帰宅日として選択できないこと" do
        find("#departure_date", visible: false).sibling("input").click
        find('div.dayContainer > span:nth-child(2)').click
        sleep 0.3
        find("#return_date", visible: false).sibling("input").click

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

    it "成功すること" do
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "more_horiz", visible: false).click
        click_on "削除"

        expect(page).to have_content "この旅のプランを削除しますか？この操作は取り消せません。"

        click_on "削除する"

        expect(page).to have_content "旅のプランを削除しました。"
        expect(page).not_to have_content itinerary.title
        expect(current_path).to eq itineraries_path
      }.to change(Itinerary, :count).by(-1)
    end
  end
end
