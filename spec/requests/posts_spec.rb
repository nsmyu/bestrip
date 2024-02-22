require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary_1) { create(:itinerary, :with_schedule, owner: user) }
  let(:itinerary_2) { create(:itinerary, :with_schedule, owner: user) }
  let(:post_1) { create(:post, :caption_great_with_hashtag, :with_photo, itinerary: itinerary_1) }
  let(:post_2) { create(:post, :caption_awesome_no_hashtag, :with_photo, itinerary: itinerary_2) }
  let(:comment_1) { create(:comment, user: user, post: post_1) }
  let(:comment_2) { create(:comment, user: other_user, post: post_1) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  describe "GET #index" do
    before do
      post_1
      post_2
      get posts_path
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿を全て取得すること" do
      expect(response.body).to include post_1.title, post_2.title
    end

    it "投稿のタイトル、投稿者名、投稿日を取得すること" do
      expect(response.body).to include post_1.title
      expect(response.body).to include I18n.l post_1.created_at, format: :date_posted
      expect(response.body).to include post_1.user.name
    end
  end

  describe "GET #search" do
    before do
      post_1
      post_2
      get posts_path
    end

    it "タイトルにキーワードが含まれる投稿を取得すること" do
      get search_posts_path(keyword: post_1.title.slice(/Trip_\d+/))
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end

    it "キャプションにキーワードが含まれる投稿を取得すること" do
      get search_posts_path(keyword: "great")
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end

    it "関連付けられたプランのスケジュールにキーワードが含まれる投稿を全て取得すること" do
      get search_posts_path(keyword: post_1.itinerary.schedules[0].title)
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end

    it "キーワードに該当する投稿が無い場合、その旨メッセージを取得すること" do
      get search_posts_path(keyword: "find_nothing")
      expect(response.body).to include "「find_nothing」に一致する投稿は見つかりませんでした"
    end
  end

  describe "GET #new" do
    before do
      sign_in user
    end

    it "正常にレスポンスを返すこと" do
      get new_post_path
      expect(response).to have_http_status 200
    end

    it "ログインユーザーが参加している旅のプラン全てを取得すること" do
      itinerary_1
      other_users_itinerary = create(:itinerary, owner: other_user)
      other_users_itinerary.members << user
      get new_post_path
      expect(response.body).to include itinerary_1.title, other_users_itinerary.title
    end

    it "ログインユーザーが招待されているが参加していない旅のプランの情報を取得しないこと" do
      create(:itinerary_user, user: other_user, itinerary: itinerary_1, confirmed: false)
      sign_in other_user
      get new_post_path
      expect(response.body).not_to include itinerary_1.title
    end
  end

  describe "POST #create" do
    before do
      sign_in user
    end

    context "有効な値の場合" do
      it "成功すること" do
        photo_params = { photos_attributes: [attributes_for(:photo)] }
        post_params = attributes_for(:post, itinerary_id: itinerary_1.id).merge(photo_params)
        post posts_path, params: { post: post_params }
        expect(response).to redirect_to post_path(Post.all[0].id)
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        post_params = attributes_for(:post, title: "")
        post posts_path, params: { post: post_params }, headers: turbo_stream
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, title: "a" * 31)
        post posts_path, params: { post: post_params }, headers: turbo_stream
        expect(response.body).to include "タイトルは30文字以内で入力してください"
      end

      it "キャプションが1001文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, caption: "a" * 1001)
        post posts_path, params: { post: post_params }, headers: turbo_stream
        expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
      end

      it "旅のプランが選択されていない場合、失敗すること" do
        post_params = attributes_for(:post, itinerary_id: nil)
        post posts_path, params: { post: post_params }, headers: turbo_stream
        expect(response.body).to include "旅のプランを選択してください"
      end

      it "写真が1枚も選択されていない場合、失敗すること" do
        post_params = attributes_for(:post)
        post posts_path, params: { post: post_params }, headers: turbo_stream
        expect(response.body).to include "写真は1枚以上選択してください"
      end
    end
  end

  describe "GET #show" do
    before do
      get post_path(id: post_1.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿の各情報、関連付けられたプランのスケジュールを取得すること" do
      expect(response.body).to include post_1.title
      expect(response.body).to include post_1.caption.slice(/[\w\s]+!/)
      expect(response.body).to include I18n.l post_1.created_at, format: :date_posted
      expect(response.body).to include post_1.user.name
      expect(response.body).to include post_1.itinerary.schedules[0].title
    end

    describe "投稿へのコメント" do
      before do
        comment_1
        comment_2
      end

      it "ユーザーがログインしている場合、投稿へのコメントを全て取得すること" do
        sign_in user
        get post_path(id: post_1.id)
        expect(response.body).to include comment_1.user.name, comment_1.content
        expect(response.body).to include comment_2.user.name, comment_2.content
      end

      it "ユーザーがログインしていない場合、ログインを促すメッセージを取得すること" do
        get post_path(id: post_1.id)
        expect(response.body).to include "ログインすると、投稿に「いいね♡」やコメントができます。"
      end
    end
  end

  describe "GET #edit" do
    context "ログインユーザーが投稿者の場合" do
      before do
        sign_in user
        get edit_post_path(id: post_1.id)
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "投稿のタイトル、キャプション、関連付けられたプランのタイトルを取得すること" do
        expect(response.body).to include post_1.title
        expect(response.body).to include post_1.caption
        expect(response.body).to include post_1.itinerary.title
      end
    end

    context "ログインユーザーが投稿者ではない場合" do
      it "rootにリダイレクトされること" do
        sign_in other_user
        get edit_post_path(id: post_1.id)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "PATCH #update" do
    context "ログインユーザーが投稿者の場合" do
      before do
        sign_in user
      end

      context "有効な値の場合" do
        it "成功すること" do
          post_params = attributes_for(:post, :with_photo, title: "Edited Title",
                                                           caption: "Edited caption.",
                                                           itinerary_id: itinerary_2.id)
          patch post_path(id: post_1.id), params: { post: post_params }
          expect(response).to redirect_to post_path(post_1.id)
          expect(post_1.reload.title).to eq "Edited Title"
          expect(post_1.reload.caption).to eq "Edited caption."
          expect(post_1.reload.itinerary_id).to eq itinerary_2.id
        end
      end

      context "無効な値の場合" do
        it "タイトルが空欄の場合、失敗すること" do
          post_params = attributes_for(:post, title: "")
          patch post_path(id: post_1.id), params: { post: post_params },
                                          headers: turbo_stream
          expect(response.body).to include "タイトルを入力してください"
          expect(post_1.reload.title).to eq post_1.title
        end

        it "タイトルが31文字以上の場合、失敗すること" do
          post_params = attributes_for(:post, title: "a" * 31)
          patch post_path(id: post_1.id), params: { post: post_params },
                                          headers: turbo_stream
          expect(response.body).to include "タイトルは30文字以内で入力してください"
          expect(post_1.reload.title).to eq post_1.title
        end

        it "キャプションが1001文字以上の場合、失敗すること" do
          post_params = attributes_for(:post, caption: "a" * 1001)
          patch post_path(id: post_1.id), params: { post: post_params },
                                          headers: turbo_stream
          expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
          expect(post_1.reload.caption).to eq post_1.caption
        end

        it "itineraryが選択されていない場合、失敗すること" do
          post_params = attributes_for(:post, itinerary_id: nil)
          patch post_path(id: post_1.id), params: { post: post_params },
                                          headers: turbo_stream
          expect(response.body).to include "旅のプランを選択してください"
          expect(post_1.reload.itinerary_id).to eq post_1.itinerary_id
        end

        it "写真が1枚も選択されていない（既存の写真が削除される）場合、失敗すること" do
          photo_delete_params =
            { photos_attributes: [id: post_1.photos[0].id, _destroy: true] }
          post_params = attributes_for(:post,).merge(photo_delete_params)
          patch post_path(id: post_1.id), params: { post: post_params },
                                          headers: turbo_stream
          expect(response.body).to include "写真は1枚以上選択してください"
        end
      end
    end

    context "ログインユーザーが投稿者ではない場合" do
      it "失敗すること（rootにリダイレクトされること）" do
        sign_in other_user
        post_params = attributes_for(:post, title: "Edited Title")
        patch post_path(id: post_1.id), params: { post: post_params },
                                        headers: turbo_stream
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "ログインユーザーが投稿者の場合" do
      it "成功すること" do
        sign_in user
        delete post_path(id: post_1.id)
        expect(user.reload.posts).not_to include post_1
      end
    end

    context "ログインユーザーが投稿者ではない場合" do
      it "失敗すること" do
        sign_in other_user
        delete post_path(id: post_1.id)
        expect(user.reload.posts).to include post_1
      end
    end
  end
end
