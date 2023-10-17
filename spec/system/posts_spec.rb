require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, :with_schedule, owner: user) }

  let(:photo) { build(:photo) }

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
        expect(page).to have_selector "img[src$='test_image.jpg']"
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
    let(:post) { build(:post) }

    before do
      visit new_post_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          find(".select-box").click
          find("option", text: "#{itinerary.title}").click
          image_path = Rails.root.join('spec/fixtures/test_image.jpg')
          attach_file "post[photos_attributes][0][url]", image_path, make_visible: true
          fill_in "post[title]", with: post.title
          fill_in "post[caption]", with: post.caption
          click_on "投稿する"

          expect(page).to have_content "旅の思い出を投稿しました。"
          expect(page).to have_selector "img[src$='test_image.jpg']"
          expect(page).to have_content post.title
          expect(page).to have_content post.caption
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

  describe "詳細表示", js: true, focus: true do
    let!(:post) { create(:post, itinerary: itinerary) }

    before do
      visit post_path(id: post.id)
    end

    it "投稿の各情報を表示すること" do
      expect(page).to have_selector "img[src$='test_image.jpg']"
      expect(page).to have_content post.title
      expect(page).to have_content post.user.name
      expect(page).to have_content post.caption
      expect(page).to have_content date_posted(post)
    end

    it "投稿に紐付けられた旅のプランのスケジュールを表示すること" do
      expect(page).to have_content post.itinerary.schedule[0].icon
      expect(page).to have_content post.itinerary.schedule[0].title
      expect(page).to have_content I18n.l post.itinerary.schedule[0].start_at
    end
  end

  describe "編集", js: true do
    let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

    before do
      visit edit_post_path(id: post.id)
    end

    context "有効な値の場合" do
      it "成功すること" do
        other_itinerary = create(:itinerary, owner: user)
        visit edit_post_path(id: post.id)
        find(".select-box").click
        find("option", text: "#{other_itinerary.title}").click
        fill_in "post[title]", with: "New title"
        fill_in "post[caption]", with: "New caption."
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
        # within(:xpath, "//div[h5[contains(text(), '#{I18n.l post.post_date}')]]") do
        #   expect(page).to have_content post.title
        #   expect(page).to have_content post.icon
        #   expect(page).to have_content I18n.l post.start_at
        #   expect(page).to have_content I18n.l post.end_at
        #   expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"
        # end
        # expect(current_path).to eq itinerary_posts_path(itinerary_id: itinerary.id)

        # find(".post-dropdown-icon", match: :first).click
        # click_on "情報を見る", match: :first

        # expect(page).to have_content post.note
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        find(".select-box").click
        find("option", text: "旅のプランを選択").click
        find("i", text: "close").click
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
        fill_in "post[caption]", with: "a" * 1000

        expect(page).to have_content "1000"
        expect(find("#submit_btn")).not_to be_disabled

        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  # describe "削除", js: true do
  #   let!(:post) { create(:post, itinerary: itinerary) }

  #   it "成功すること" do
  #     expect {
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       find(".post-dropdown-icon", match: :first).click
  #       click_on "削除", match: :first

  #       expect(page).to have_content "このスケジュールを削除しますか？この操作は取り消せません。"

  #       click_on "削除する"

  #       expect(page).to have_content "スケジュールを削除しました。"
  #       expect(current_path).to eq itinerary_posts_path(itinerary_id: itinerary.id)
  #     }.to change(Schedule, :count).by(-1)
  #   end
  # end
end
