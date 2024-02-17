require 'rails_helper'

RSpec.describe "Comments", type: :system do
  let(:user) { create(:user) }
  let(:test_post) { create(:post, :caption_great_with_hashtag, :with_photo) }
  let(:comment) { create(:comment, post: test_post) }
  let(:reply) { create(:comment, post: test_post, parent: comment) }

  before do
    sign_in user
  end

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

  describe "投稿詳細ページのコメント表示" do
    it "投稿へのコメント数（返信含む）を表示すること" do
      create_list(:comment, 3, post: test_post)
      create_list(:comment, 2, post: test_post, parent: test_post.comments.first)
      visit post_path(id: test_post.id)

      expect(find("#comments_count")).to have_content "5"
    end

    context "ユーザーがログインしていない場合" do
      before do
        sign_out user
        visit post_path(id: test_post.id)
      end

      it "コメントが表示されないこと" do
        comment
        visit post_path(id: test_post.id)

        expect(page).not_to have_content comment.content
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
        comment
      end

      it "投稿へのコメントを、コメント投稿日時の降順で表示すること" do
        comment_2 = create(:comment, post: test_post)
        comment_3 = create(:comment, post: test_post)
        visit post_path(id: test_post.id)

        expect(page.text)
          .to match(/#{comment_3.content}[\s\S]*#{comment_2.content}[\s\S]*#{comment.content}/)
      end

      it "ログインユーザーのコメントを一番上に表示すること" do
        own_comment = create(:comment, user: user, post: test_post)
        comment_2 = create(:comment, post: test_post)
        visit post_path(id: test_post.id)

        expect(page.text)
          .to match(/#{own_comment.content}[\s\S]*#{comment_2.content}[\s\S]*#{comment.content}/)
      end

      it "コメント投稿者のプロフィール画像及びニックネーム、コメント本文を表示すること" do
        visit post_path(id: test_post.id)
        expect(page).to have_selector "img[src*='default_avatar']"
        expect(page).to have_content comment.user.name
        expect(page).to have_content comment.content
      end

      it "コメント投稿者のプロフィール画像/ニックネームをクリックすると、投稿者のプロフィールページへ遷移すること" do
        visit post_path(id: test_post.id)
        click_on "#{comment.user.name}のプロフィール画像"

        expect(current_path).to eq user_path(id: comment.user.id)

        visit post_path(id: test_post.id)
        click_on comment.user.name

        expect(current_path).to eq user_path(id: comment.user.id)
      end
    end
  end

  describe "コメントの作成" do
    before do
      visit post_path(id: test_post.id)
    end

    context "有効な値の場合" do
      it "成功すること（投稿へのコメント数が更新され、既存のコメントの上に新たなコメントが表示される）", js: true do
        comment
        new_comment = build(:comment)
        visit post_path(id: test_post.id)
        expect(find("#comments_count")).to have_content "1"

        expect {
          fill_in "comment[content]", with: new_comment.content
          find("i", text: "send").click

          expect(find("#comments_count")).to have_content "2"
          expect(page.text).to match(/#{new_comment.content}[\s\S]*#{comment.content}/)
        }.to change(Comment, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "コメント入力欄が未入力の場合、送信ボタンが無効化されていること" do
        expect(find('#submit_btn')).to be_disabled
      end

      it "コメント入力欄に空白のみが入力された場合、送信ボタンが無効化されていること", js: true do
        fill_in "comment[content]", with: " "

        expect(find('#submit_btn')).to be_disabled
      end

      it "コメント入力欄に1001文字以上入力された場合、送信ボタンが無効化されていること", js: true do
        fill_in "comment[content]", with: "a" * 1001

        expect(find('#submit_btn')).to be_disabled
      end
    end
  end

  describe "コメントの削除" do
    before do
      comment
    end

    context "有効な値の場合", js: true do
      it "ログインユーザーがコメント投稿者の場合、成功すること" do
        sign_in comment.user
        visit post_path(id: test_post.id)

        expect(find("#comments_count")).to have_content "1"

        expect {
          within("turbo-frame#comment_#{comment.id}") do
            click_on "削除"
          end
          click_on "削除する"

          expect(page).not_to have_content comment.content
          expect(find("#comments_count")).to have_content "0"
        }.to change(Comment, :count).by(-1)
      end

      it "ログインユーザーがpost投稿者の場合、成功すること" do
        sign_in test_post.user
        visit post_path(id: test_post.id)

        expect(find("#comments_count")).to have_content "1"

        expect {
          within("turbo-frame#comment_#{comment.id}") do
            click_on "削除"
          end
          click_on "削除する"

          expect(page).not_to have_content comment.content
          expect(find("#comments_count")).to have_content "0"
        }.to change(Comment, :count).by(-1)
      end

      it "コメントが削除されると、削除されたコメントへの返信も削除されること" do
        sign_in comment.user
        reply
        visit post_path(id: test_post.id)

        expect(find("#comments_count")).to have_content "2"

        expect {
          within("turbo-frame#comment_#{comment.id}") do
            click_on "削除"
          end
          click_on "削除する"

          expect(page).not_to have_content reply.content
          expect(find("#comments_count")).to have_content "0"
        }.to change(Comment, :count).by(-2)
      end
    end

    context "無効な値の場合" do
      it "ログインユーザーがコメントの投稿者でもpostの投稿者でもない場合、「削除」ボタンが表示されないこと" do
        random_user = create(:user)
        sign_in random_user
        visit post_path(id: test_post.id)

        expect(page).not_to have_link "削除", href: "/posts/#{test_post.id}/comments/#{comment.id}"
      end
    end
  end

  describe "コメントへの返信の表示", js: true do
    before do
      reply
    end

    it "コメントへの返信の表示/非表示の切り替えができること" do
      visit post_path(id: test_post.id)
      within("turbo-frame#comment_#{comment.id}") do
        click_on "返信1件を表示する"

        expect(page).to have_content reply.content

        click_on "返信を非表示にする"

        expect(page).not_to have_content reply.content
      end
    end

    it "コメントへの返信を、返信日時の昇順で表示すること" do
      reply_2 = create(:comment, post: test_post, parent: comment)
      reply_3 = create(:comment, post: test_post, parent: comment)
      visit post_path(id: test_post.id)

      within("turbo-frame#comment_#{comment.id}") do
        click_on "返信3件を表示する"

        expect(page).to have_content "返信を非表示にする"
        expect(page.text)
          .to match(/#{reply.content}[\s\S]*#{reply_2.content}[\s\S]*#{reply_3.content}/)
      end
    end
  end

  describe "コメントへの返信作成" do
    before do
      comment
    end

    it "成功すること（投稿へのコメント数が更新され、既存の返信の下に新たな返信が表示される）", js: true do
      reply
      new_reply = build(:comment)
      visit post_path(id: test_post.id)

      expect(find("#comments_count")).to have_content "2"

      within("turbo-frame#comment_#{comment.id}") do
        click_on "返信"
      end
      click_on "返信1件を表示する"

      expect {
        fill_in "comment[content]", with: new_reply.content
        find("i", text: "send").click

        expect(find("#comments_count")).to have_content "3"
        within("turbo-frame#comment_#{comment.id}") do
          expect(page.text).to match(/#{reply.content}[\s\S]*#{new_reply.content}/)
        end
      }.to change(Comment, :count).by(1)
    end

    it "コメント下の「返信」ボタンを押すと、コメント入力欄が返信入力欄に変わり、キャンセルボタンを押すとコメント入力欄に戻ること" do
      visit post_path(id: test_post.id)
      within("turbo-frame#comment_#{comment.id}") do
        click_on "返信"
      end

      expect(page).to have_xpath "//textarea[@placeholder='#{comment.user.name}さんに返信…']"

      find("a#reply_cancel_btn").click

      expect(page).to have_xpath "//textarea[@placeholder='コメントを入力…']"
    end
  end

  describe "post投稿者のプロフィールページ", focus: true do
    it "投稿へのコメント数（返信含む）を表示すること" do
      create_list(:comment, 3, post: test_post)
      create_list(:comment, 2, post: test_post, parent: test_post.comments.first)
      visit user_path(id: test_post.user.id)

      within("turbo-frame#post_#{test_post.id}") do
        expect(page).to have_content "5"
      end
    end
  end
end
