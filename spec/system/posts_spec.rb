require 'rails_helper'

RSpec.describe "Posts", type: :system, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, :with_schedule, owner: user) }

  before do
    sign_in user
  end

  describe "一覧表示" do
    let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

    before do
      visit posts_path
    end

    it "投稿を作成日の降順で表示すること" do
      now = Time.current
      post_2_days_ago = create(:post, :with_photo, created_at: now.ago(2.days), itinerary: itinerary)
      post_yesterday = create(:post, :with_photo, created_at: now.yesterday, itinerary: itinerary)
      post_today = create(:post, :with_photo, created_at: now, itinerary: itinerary)
      visit posts_path

      expect(page.text)
        .to match(/#{post_today.title}[\s\S]*#{post_yesterday.title}[\s\S]*#{post_2_days_ago.title}/)
    end

    it "投稿のタイトル、写真、投稿者名、投稿日を表示すること" do
      within(:xpath, "//div[div[p[contains(text(), '#{post.title}')]]]") do
        expect(page).to have_selector "img[src$='cat.jpg']"
        expect(page).to have_content post.user.name
        expect(page).to have_content date_posted(post)
      end
    end

    it "投稿をクリックすると、投稿詳細ページへ遷移すること" do
      click_on post.title

      expect(current_path).to eq post_path(post.id)
      expect(page).to have_content post.title
    end

    it "「旅の思い出を投稿」をクリックすると、投稿作成モーダルを表示すること", js: true do
      click_on "旅の思い出を投稿"

      within(".modal") do
        expect(page).to have_content "旅の思い出を投稿"
      end
    end
  end

  describe "新規作成", js: true do
    let(:new_post) { build(:post) }

    before do
      visit new_post_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          find(".select-box").click
          find("option", text: "#{itinerary.title}").click
          image_path = Rails.root.join('spec/fixtures/cat.jpg')
          attach_file "post[photos_attributes][0][url]", image_path, make_visible: true
          fill_in "post[title]", with: new_post.title
          fill_in "post[caption]", with: new_post.caption
          click_on "投稿する"

          expect(page).to have_content "旅の思い出を投稿しました。"
          expect(page).to have_selector "img[src$='cat.jpg']"
          expect(page).to have_content new_post.title
          expect(page).to have_content new_post.caption
        }.to change(Post, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        expect {
          click_on "投稿する"

          expect(page).to have_content "旅のプランを選択してください"
          expect(page).to have_content "写真は1枚以上選択してください"
          expect(page).to have_content "タイトルを入力してください"
        }.not_to change(Post, :count)
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        expect {
          fill_in "post[title]", with: "a" * 31
          click_on "投稿する"

          expect(page).to have_content "タイトルは30文字以内で入力してください"
        }.not_to change(Post, :count)
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが無効化されること" do
        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  describe "詳細表示" do
    let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

    before do
      visit post_path(id: post.id)
    end

    it "投稿の各情報を表示すること" do
      expect(page).to have_selector "img[src$='cat.jpg']"
      expect(page).to have_content post.title
      expect(page).to have_content post.user.name
      expect(page).to have_content post.caption
      expect(page).to have_content date_posted(post)
    end

    it "投稿に紐付けられた旅のプランの、スケジュール情報を表示すること" do
      expect(page).to have_content I18n.l post.itinerary.schedules[0].start_at
      expect(page).to have_content post.itinerary.schedules[0].icon
      expect(page).to have_content post.itinerary.schedules[0].title
    end

    it "投稿に紐付けられた旅のプランのスケジュールを日付順で表示すること" do
      schedule_1st_day = create(:schedule, schedule_date: itinerary.departure_date,
                                           itinerary: itinerary)
      schedule_2nd_day = create(:schedule, schedule_date: itinerary.departure_date.tomorrow,
                                           itinerary: itinerary)
      schedule_8th_day = create(:schedule, schedule_date: itinerary.return_date,
                                           itinerary: itinerary)

      visit post_path(id: post.id)

      expect(page.text).to match(/#{"1日目"}[\s\S]*#{"2日目"}[\s\S]*#{"8日目"}/)
      within(:xpath, "//div[h6[contains(text(), '1日目')]]") do
        expect(page).to have_content I18n.l schedule_1st_day.start_at
      end
      within(:xpath, "//div[h6[contains(text(), '2日目')]]") do
        expect(page).to have_content I18n.l schedule_2nd_day.start_at
      end
      within(:xpath, "//div[h6[contains(text(), '8日目')]]") do
        expect(page).to have_content I18n.l schedule_8th_day.start_at
      end
    end

    describe "リンクのテスト", js: true do
      it "ドロップダウンメニューの「編集」をクリックすると、投稿編集モーダルを表示すること" do
        find("i", text: "more_horiz", visible: false).click
        click_on "編集"

        within(".modal") do
          expect(page).to have_content "旅の思い出を編集"
          expect(page.has_field? 'post[title]', with: post.title).to be_truthy
        end
      end

      it "スケジュールのタイトル右側のアイコンをクリックすると、スポット情報のモーダルを表示すること" do
        find("i", text: "pin_drop", visible: false).click

        within(".modal") do
          expect(page).to have_content "スポット情報"
          expect(page).to have_content "シドニー・オペラハウス"
        end
      end
    end
  end

  describe "編集", js: true do
    let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

    before do
      visit edit_post_path(id: post.id)
    end

    context "有効な値の場合" do
      it "画像以外の各項目の変更に成功すること" do
        other_itinerary = create(:itinerary, owner: user)

        visit edit_post_path(id: post.id)
        find(".select-box").click
        find("option", text: "#{other_itinerary.title}").click
        fill_in "post[title]", with: "Edited title"
        fill_in "post[caption]", with: "Edited caption."
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
        expect(page).to have_content "Edited title"
        expect(page).to have_content "Edited caption."
      end

      it "画像の変更に成功すること" do
        expect(page).to have_selector "img[src$='cat.jpg']"

        find("#delete_btn_0").click
        image_path = Rails.root.join('spec/fixtures/turtle.jpg')
        attach_file "post[photos_attributes][1][url]", image_path, make_visible: true
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
        expect(page).not_to have_selector "img[src$='cat.jpg']"
        expect(page).to have_selector "img[src$='turtle.jpg']"
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        find(".select-box").click
        find("option", text: "旅のプランを選択").click
        find("#delete_btn_0").click
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "旅のプランを選択してください"
        expect(page).to have_content "写真は1枚以上選択してください"
        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが空欄の場合、失敗すること" do
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        fill_in "post[title]", with: "a" * 31
        click_on "投稿する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが押せないこと" do
        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  describe "削除", js: true do
    let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

    it "成功すること" do
      expect {
        visit post_path(id: post.id)
        find("i", text: "more_horiz", visible: false).click
        click_on "削除"

        expect(page).to have_content "この投稿を削除しますか？この操作は取り消せません。"

        click_on "削除する"

        expect(page).to have_content "投稿を削除しました。"
        expect(current_path).to eq posts_path
      }.to change(Post, :count).by(-1)
    end
  end
end
