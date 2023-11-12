require 'rails_helper'

RSpec.describe "Posts", type: :request, focus: true do
  let!(:user) { create(:user) }
  let!(:itinerary_1) { create(:itinerary, :with_schedule, owner: user) }
  let!(:itinerary_2) { create(:itinerary, :with_schedule, owner: user) }
  let!(:post_1) { create(:post, :with_photo, caption: "caption_1", itinerary: itinerary_1) }
  let!(:post_2) { create(:post, :with_photo, caption: "caption_2", itinerary: itinerary_2) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get posts_path
      expect(response).to have_http_status 200
    end

    it "投稿を全て取得すること" do
      get posts_path
      expect(response.body).to include post_1.title, post_2.title
    end

    it "投稿のタイトル、投稿者名、投稿日を取得すること" do
      get posts_path
      expect(response.body).to include post_1.title
      expect(response.body).to include I18n.l post_1.created_at, format: :date_posted
      expect(response.body).to include post_1.user.name
    end
  end

  describe "GET #search" do
    before do
      get posts_path
    end

    it "タイトルにキーワードが含まれる投稿を取得すること" do
      get search_posts_path(keyword: post_1.title)
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end

    it "キャプションにキーワードが含まれる投稿を取得すること" do
      get search_posts_path(keyword: post_1.caption)
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end

    it "関連付けられたプランのスケジュールにキーワードが含まれる投稿を全て取得すること" do
      get search_posts_path(keyword: post_1.itinerary.schedules[0].title)
      expect(response.body).to include post_1.title
      expect(response.body).not_to include post_2.title
    end
  end

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get new_post_path
      expect(response).to have_http_status 200
    end
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        photo_params = { photos_attributes: [attributes_for(:photo)] }
        post_params = attributes_for(:post, itinerary_id: itinerary_1.id).merge(photo_params)
        post posts_path, params: { post: post_params }
        expect(response).to redirect_to post_path(Post.all[2].id)
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

      it "itineraryが選択されていない場合、失敗すること" do
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

    it "投稿の各情報を取得すること" do
      expect(response.body).to include post_1.title
      expect(response.body).to include post_1.caption
      expect(response.body).to include I18n.l post_1.created_at, format: :date_posted
      expect(response.body).to include post_1.user.name
      expect(response.body).to include post_1.itinerary.schedules[0].title
    end
  end

  describe "GET #edit" do
    before do
      get edit_post_path(id: post_1.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿の編集可能な項目の値を取得すること" do
      expect(response.body).to include post_1.title
      expect(response.body).to include post_1.caption
      expect(response.body).to include post_1.itinerary.title
    end
  end

  describe "PATCH #update" do
    context "有効な値の場合" do
      it "各項目の変更に成功すること" do
        other_itinerary = create(:itinerary, owner: user)
        post_params = attributes_for(:post, :with_photo, title: "Edited Title",
                                                         caption: "Edited caption.",
                                                         itinerary_id: other_itinerary.id)
        patch post_path(id: post_1.id), params: { post: post_params }
        expect(response).to redirect_to post_path(post_1.id)
        expect(post_1.reload.title).to eq "Edited Title"
        expect(post_1.reload.caption).to eq "Edited caption."
        expect(post_1.reload.itinerary_id).to eq other_itinerary.id
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        post_params = attributes_for(:post, title: "")
        patch post_path(id: post_1.id), params: { post: post_params },
                                        headers: turbo_stream
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, title: "a" * 31)
        patch post_path(id: post_1.id), params: { post: post_params },
                                        headers: turbo_stream
        expect(response.body).to include "タイトルは30文字以内で入力してください"
      end

      it "キャプションが1001文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, caption: "a" * 1001)
        patch post_path(id: post_1.id), params: { post: post_params },
                                        headers: turbo_stream
        expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
      end

      it "itineraryが選択されていない場合、失敗すること" do
        post_params = attributes_for(:post, itinerary_id: nil)
        patch post_path(id: post_1.id), params: { post: post_params },
                                        headers: turbo_stream
        expect(response.body).to include "旅のプランを選択してください"
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

  describe "DELETE #destroy" do
    it "成功すること" do
      delete post_path(id: post_1.id)
      expect(response).to redirect_to posts_path
    end
  end
end
