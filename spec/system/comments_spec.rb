require 'rails_helper'

RSpec.describe "Comments", type: :system, focus: true do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: other_user) }
  let!(:test_post) { create(:post, :caption_great_with_hashtag, :with_photo, itinerary: itinerary) }
  let(:comment_1) { create(:comment, post: test_post) }
  let(:comment_2) { create(:comment, post: test_post) }
  let(:reply_1) { create(:comment, post: test_post, parent: comment_1) }
  let(:reply_2) { create(:comment, post: test_post, parent: comment_1) }

  describe "投稿一覧ページ" do
    it "投稿へのコメント数（返信含む）を表示すること" do
      create_list(:comment, 3, post: test_post)
      create_list(:comment, 2, post: test_post, parent: test_post.comments.first)
      visit posts_path

      within("turbo-frame#post_#{test_post.id}") do
        expect(page).to have_content "5"
      end
    end
  end

  describe "投稿詳細ページのコメント表示部分" do
    it "投稿へのコメント数（返信含む）を表示すること" do
      create_list(:comment, 3, post: test_post)
      create_list(:comment, 2, post: test_post, parent: test_post.comments.first)
      visit post_path(id: test_post.id)

      expect(find("#comments_count")).to have_content "5"
    end

    context "ユーザーがログインしていない場合" do
      before do
        visit post_path(id: test_post.id)
      end

      it "コメントが表示されないこと" do
        comment_1
        visit post_path(id: test_post.id)

        expect(page).not_to have_content comment_1.content
      end

      it "コメント入力欄が無効化されていること" do
        expect(find('textarea')).to be_disabled
      end

      it "ログインを促すメッセージ、ログイン画面及びアカウント登録画面へのリンクが表示されること" do
        within(:xpath, "//div[p[contains(text(), 'ログインすると、投稿に「いいね♡」やコメントができます。')]]") do
          click_on "ログイン"

          expect(current_path).to eq new_user_session_path

          visit post_path(id: test_post.id)
          click_on "アカウント登録"

          expect(current_path).to eq new_user_registration_path
        end
      end
    end

    context "ユーザーがログイン済みの場合" do
      before do
        comment_1
        comment_2
        sign_in user
        visit post_path(id: test_post.id)
      end

      it "投稿へのコメントを全て表示すること" do
        expect(page).to have_content comment_1.content
        expect(page).to have_content comment_2.content
      end

      it "コメント投稿者のプロフィール画像及びニックネーム、コメント本文を表示すること" do
        expect(page).to have_selector "img[src*='default_avatar']"
        expect(page).to have_content comment_1.user.name
        expect(page).to have_content comment_1.content
      end

      it "コメント投稿者のプロフィール画像/ニックネームをクリックすると、投稿者のプロフィールページへ遷移すること" do
        click_on "#{comment_1.user.name}のプロフィール画像"

        expect(current_path).to eq user_path(id: comment_1.user.id)

        visit post_path(id: test_post.id)
        click_on comment_1.user.name

        expect(current_path).to eq user_path(id: comment_1.user.id)
      end

      it "コメントへの返信の表示/非表示の切り替えができること", js: true do
        reply_1
        reply_2
        visit post_path(id: test_post.id)
        click_on "返信2件を表示する"

        expect(page).to have_content reply_1.content
        expect(page).to have_content reply_2.content

        click_on "返信を非表示にする"

        expect(page).not_to have_content reply_1.content
        expect(page).not_to have_content reply_2.content
      end
    end
  end

  describe "コメントの投稿" do
    let(:comment) { build(:comment) }

    before do
      sign_in user
      visit post_path(id: test_post.id)
    end

    context "有効な値の場合" do
      it "成功すること", js: true do
        expect(find("#comments_count")).to have_content "0"

        expect {
          fill_in "comment[content]", with: comment.content

          find("i", text: "send").click

          expect(page).to have_content user.name
          expect(page).to have_content comment.content
          expect(find("#comments_count")).to have_content "1"
        }.to change(Comment, :count).by(1)
      end
    end

    context "無効な値の場合", js:true do
      it "コメント入力欄が未入力の場合、送信ボタンが無効化されていること" do
        expect(find('#submit_btn')).to be_disabled
      end

      it "コメント入力欄に空白のみが入力された場合、送信ボタンが無効化されていること" do
        fill_in "comment[content]", with: " "

        expect(find('#submit_btn')).to be_disabled
      end

      it "コメント入力欄に1001文字以上入力された場合、送信ボタンが無効化されていること" do
        fill_in "comment[content]", with: "a" * 1001

        expect(find('#submit_btn')).to be_disabled
      end
    end
  end
end
