require "rails_helper"

RSpec.describe "Likes", type: :system do
  let(:user) { create(:user) }
  let(:test_post) { create(:post, :caption_great_with_hashtag, :with_photo) }

  describe "投稿一覧ページ" do
    it "投稿へのいいね数を表示すること" do
      create_list(:like, 16, post: test_post)
      visit posts_path

      within("turbo-frame#post_#{test_post.id}") do
        expect(page).to have_content "16"
      end
    end

    context "ユーザーがログインしていない場合" do
      it "「いいね」ボタンが無効化されていること" do
        test_post
        visit posts_path

        within("turbo-frame#post_#{test_post.id}") do
          expect(find(:xpath, "//button[i[contains(text(), 'favorite_border')]]")).to be_disabled
        end
      end
    end

    context "ユーザーがログイン済みの場合", js: true do
      before do
        sign_in user
      end

      it "「いいね」ボタンをクリックすると、投稿に「いいね」ができること（いいね数更新、ボタンが削除用リンクに変化）" do
        test_post
        visit posts_path

        expect {
          within("turbo-frame#post_#{test_post.id}") do
            expect(page).to have_content "0"

            find("i", text: "favorite_border").click

            expect(page).to have_content "1"
            expect(page).to have_xpath "//a[i[contains(text(), 'favorite')]]"
          end
        }.to change(Like, :count).by(1)
      end

      it "「いいね」済みの場合「いいね」ボタンをクリックすると「いいね」が削除できること（いいね数更新、ボタンが作成用フォームに変化）" do
        create(:like, user: user, post: test_post)
        visit posts_path

        expect {
          within("turbo-frame#post_#{test_post.id}") do
            expect(page).to have_content "1"

            find("i", text: "favorite").click

            expect(page).to have_content "0"
            expect(page).to have_xpath "//form[button[i[contains(text(), 'favorite_border')]]]"
          end
        }.to change(Like, :count).by(-1)
      end
    end
  end

  describe "投稿詳細ページ" do
    it "投稿へのいいね数を表示すること" do
      create_list(:like, 16, post: test_post)
      visit post_path(id: test_post.id)

      within("div#like_#{test_post.id}") do
        expect(page).to have_content "16"
      end
    end

    context "ユーザーがログインしていない場合" do
      it "「いいね」ボタンが無効化されていること" do
        visit post_path(id: test_post.id)

        within("div#like_#{test_post.id}") do
          expect(find(:xpath, "//button[i[contains(text(), 'favorite_border')]]")).to be_disabled
        end
      end
    end

    context "ユーザーがログイン済みの場合", js: true do
      before do
        sign_in user
      end

      it "「いいね」ボタンをクリックすると、投稿に「いいね」ができること（いいね数更新、ボタンが削除用リンクに変化）" do
        visit visit post_path(id: test_post.id)

        expect {
          within("div#like_#{test_post.id}") do
            expect(page).to have_content "0"

            find("i", text: "favorite_border").click

            expect(page).to have_content "1"
            expect(page).to have_xpath "//a[i[contains(text(), 'favorite')]]"
          end
        }.to change(Like, :count).by(1)
      end

      it "「いいね」済みの場合「いいね」ボタンをクリックすると「いいね」が削除できること（いいね数更新、ボタンが作成用フォームに変化）" do
        create(:like, user: user, post: test_post)
        visit visit post_path(id: test_post.id)

        expect {
          within("div#like_#{test_post.id}") do
            expect(page).to have_content "1"

            find("i", text: "favorite").click

            expect(page).to have_content "0"
            expect(page).to have_xpath "//form[button[i[contains(text(), 'favorite_border')]]]"
          end
        }.to change(Like, :count).by(-1)
      end
    end
  end

  describe "post投稿者のプロフィールページ" do
    it "投稿へのいいね数を表示すること" do
      create_list(:like, 16, post: test_post)
      visit user_path(id: test_post.user.id)

      within("turbo-frame#post_#{test_post.id}") do
        expect(page).to have_content "16"
      end
    end

    context "ユーザーがログインしていない場合" do
      it "「いいね」ボタンが無効化されていること" do
        test_post
        visit user_path(id: test_post.user.id)

        within("turbo-frame#post_#{test_post.id}") do
          expect(find(:xpath, "//button[i[contains(text(), 'favorite_border')]]")).to be_disabled
        end
      end
    end

    context "ユーザーがログイン済みの場合", js: true do
      before do
        sign_in user
      end

      it "「いいね」ボタンをクリックすると、投稿に「いいね」ができること（いいね数更新、ボタンが削除用リンクに変化）" do
        test_post
        visit user_path(id: test_post.user.id)

        expect {
          within("turbo-frame#post_#{test_post.id}") do
            expect(page).to have_content "0"

            find("i", text: "favorite_border").click

            expect(page).to have_content "1"
            expect(page).to have_xpath "//a[i[contains(text(), 'favorite')]]"
          end
        }.to change(Like, :count).by(1)
      end

      it "「いいね」済みの場合「いいね」ボタンをクリックすると「いいね」が削除できること（いいね数更新、ボタンが作成用フォームに変化）" do
        create(:like, user: user, post: test_post)
        visit user_path(id: test_post.user.id)

        expect {
          within("turbo-frame#post_#{test_post.id}") do
            expect(page).to have_content "1"

            find("i", text: "favorite").click

            expect(page).to have_content "0"
            expect(page).to have_xpath "//form[button[i[contains(text(), 'favorite_border')]]]"
          end
        }.to change(Like, :count).by(-1)
      end
    end
  end
end
