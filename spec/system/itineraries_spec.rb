require "rails_helper"

RSpec.describe "Itineraries", type: :system, focus: true do
  describe "旅のプラン一覧表示" do
    let(:user) { create(:user) }
    let(:itinerary1) { create(:itinerary, owner: @user) }
    let(:itinerary2) { create(:itinerary, owner: @user) }

    before do
      @user = user
      sign_in @user
    end

    context "旅のプランが登録されていない場合" do
      it "登録されていない旨のメッセージを表示すること" do
        visit itineraries_path
        expect(page).to have_content "旅のプランは登録されていません"
      end
    end

    context "旅のプランが複数登録されている場合" do
      before do
        itinerary1
        itinerary2
        visit itineraries_path
      end

      it "ログインユーザーの全ての旅のプランを表示すること" do
        expect(page).to have_content itinerary1.title
        expect(page).to have_content itinerary2.title
      end

      it "他のユーザーの旅のプランが表示されていないこと" do
        other_user = create(:user, :other)
        other_users_itinerary = create(:itinerary, owner: other_user)
        expect(page).not_to have_content other_users_itinerary.title
      end

      it "旅のプランのカードをクリックすると、旅のプラン情報ページへ遷移すること" do
        click_on itinerary1.title
        expect(current_path).to eq itinerary_path(itinerary1.id)
      end
    end
  end

  describe "旅のプラン新規登録", js: true do
    let(:user) { create(:user) }
    let(:itinerary) { build(:itinerary) }

    before do
      sign_in user
      visit itineraries_path
      click_on "旅のプランを作成"
    end

    it "有効な値の場合、成功すること" do
      expect {
        fill_in "itinerary[title]", with: itinerary.title
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
        fill_in "itinerary[title]", with: itinerary.title
        click_on "保存する"

        expect(page).to have_content "出発日を入力してください"
        expect(page).to have_content "帰宅日を入力してください"
      }.not_to change(User, :count)
    end

    it "タイトルが30文字以上の場合、失敗すること" do
      expect {
        fill_in "itinerary[title]", with: "a" * 31
        fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
        fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
        click_on "保存する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
      }.not_to change(User, :count)
    end

    it "タイトルが同じユーザーで重複している場合、失敗すること" do
      itinerary = create(:itinerary, owner: user)
      expect {
        fill_in "itinerary[title]", with: itinerary.title
        fill_in "itinerary[departure_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
        fill_in "itinerary[return_date]", with: "Thu Feb 01 2024 00:00:00 GMT+0900"
        click_on "保存する"

        expect(page).to have_content "このタイトルはすでに使用されています"
      }.not_to change(User, :count)
    end

    it "出発日より前の日付は帰宅日として選択できないこと" do
      find("#departure-date-pickr").click
      find('div.dayContainer > span:nth-child(2)').click
      find("#return-date-pickr").click
      find('div.dayContainer > span:nth-child(1)').click

      click_on "保存する"

      expect(page).to have_content "帰宅日を入力してください"
    end
  end

  describe "旅のプラン情報編集", js: true do
    let(:user) { create(:user) }
    let(:itinerary1) { create(:itinerary, owner: @user) }
    let(:itinerary2) { create(:itinerary, owner: @user) }

    before do
      @user = user
      sign_in @user
      visit itinerary_path(itinerary1.id)
      find("i", text: "edit").click
    end

    it "有効な値の場合、成功すること" do
      fill_in "itinerary[title]", with: "New Title"
      fill_in "itinerary[departure_date]", with: "Mon Apr 01 2024 00:00:00 GMT+0900"
      fill_in "itinerary[return_date]", with: "Mon Apr 08 2024 00:00:00 GMT+0900"

      expect(page).to have_selector "img[id='image-preview'][src*='default_itinerary']"

      image_path = Rails.root.join('spec/fixtures/test_image.jpg')
      attach_file 'itinerary[image]', image_path, make_visible: true

      expect(page).not_to have_selector "img[id='image-preview'][src*='default_itinerary']"

      click_on "保存する"

      expect(current_path).to eq itinerary_path(itinerary1.id)
      expect(page).to have_content "旅のプラン情報を更新しました。"
      expect(page).to have_content "New Title"
      expect(page).to have_content "2024/4/1 (月) 〜 2024/4/8 (月)"
      expect(page).to have_selector "img[src*='test_image.jpg']"
    end

    it "タイトルが空欄の場合、失敗すること" do
      fill_in "itinerary[title]", with: ""
      click_on "保存する"

      expect(page).to have_content "タイトルを入力してください"
    end

    it "タイトルが30文字以上の場合、失敗すること" do
      fill_in "itinerary[title]", with: "a" * 31
      click_on "保存する"

      expect(page).to have_content "タイトルは30文字以内で入力してください"
    end

    it "タイトルが同じユーザーで重複している場合、失敗すること" do
      itinerary2 = create(:itinerary, owner: @user)
      fill_in "itinerary[title]", with: itinerary2.title
      click_on "保存する"

      expect(page).to have_content "このタイトルはすでに使用されています"
    end

    it "出発日より前の日付は帰宅日として選択できないこと" do
      find("#departure-date-pickr").click
      find('div.dayContainer > span:nth-child(2)').click
      find("#return-date-pickr").click
      find('div.dayContainer > span:nth-child(1)').click

      click_on "保存する"

      expect(page).to have_content "帰宅日を入力してください"
    end
  end
end
