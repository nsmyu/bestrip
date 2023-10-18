require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, :with_schedule, owner: user) }
  let(:post_with_photo) { create(:post, :with_photo, itinerary: itinerary) }
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
      post_with_photo_1 = create(:post, :with_photo, itinerary: itinerary)
      post_with_photo_2 = create(:post, :with_photo, itinerary: itinerary)
      get posts_path
      expect(response.body).to include post_with_photo_1.title, post_with_photo_2.title
    end

    it "投稿のタイトル、投稿者名、投稿日を取得すること" do
      post_with_photo = create(:post, :with_photo, itinerary: itinerary)
      get posts_path
      expect(response.body).to include post_with_photo.title
      expect(response.body).to include post_with_photo.user.name
      expect(response.body).to include date_posted(post_with_photo)
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
        post_params = attributes_for(:post, itinerary_id: itinerary.id).merge(photo_params)
        post posts_path, params: { post: post_params }
        expect(response).to redirect_to post_path(Post.first.id)
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
      get post_path(id: post_with_photo.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿の各情報を取得すること" do
      expect(response.body).to include post_with_photo.title
      expect(response.body).to include post_with_photo.caption
      expect(response.body).to include post_with_photo.user.name
      expect(response.body).to include date_posted(post_with_photo)
      expect(response.body).to include post_with_photo.itinerary.schedules[0].title
    end
  end

  describe "GET #edit" do
    before do
      get edit_post_path(id: post_with_photo.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿の各情報を取得すること" do
      expect(response.body).to include post_with_photo.title
      expect(response.body).to include post_with_photo.caption
      expect(response.body).to include post_with_photo.itinerary.title
    end
  end

  describe "PATCH #update" do
    context "有効な値の場合" do
      it "各項目の変更に成功すること" do
        other_itinerary = create(:itinerary, owner: user)
        post_params = attributes_for(:post, :with_photo, title: "Edited Title",
                                                         caption: "Edited caption.",
                                                         itinerary_id: other_itinerary.id)
        patch post_path(id: post_with_photo.id), params: { post: post_params }
        expect(response).to redirect_to post_path(post_with_photo.id)
        expect(post_with_photo.reload.title).to eq "Edited Title"
        expect(post_with_photo.reload.caption).to eq "Edited caption."
        expect(post_with_photo.reload.itinerary_id).to eq other_itinerary.id
      end
    end

    context "無効な値の場合" do
      it "タイトルが空欄の場合、失敗すること" do
        post_params = attributes_for(:post, title: "")
        patch post_path(id: post_with_photo.id), params: { post: post_params },
                                                 headers: turbo_stream
        expect(response.body).to include "タイトルを入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, title: "a" * 31)
        patch post_path(id: post_with_photo.id), params: { post: post_params },
                                                 headers: turbo_stream
        expect(response.body).to include "タイトルは30文字以内で入力してください"
      end

      it "キャプションが1001文字以上の場合、失敗すること" do
        post_params = attributes_for(:post, caption: "a" * 1001)
        patch post_path(id: post_with_photo.id), params: { post: post_params },
                                                 headers: turbo_stream
        expect(response.body).to include "入力内容に誤りがあります。赤字箇所をご確認ください。"
      end

      it "itineraryが選択されていない場合、失敗すること" do
        post_params = attributes_for(:post, itinerary_id: nil)
        patch post_path(id: post_with_photo.id), params: { post: post_params },
                                                 headers: turbo_stream
        expect(response.body).to include "旅のプランを選択してください"
      end

      it "写真が1枚も選択されていない（既存の写真が削除される）場合、失敗すること" do
        photo_delete_params =
          { photos_attributes: [id: post_with_photo.photos[0].id, _destroy: true] }
        post_params = attributes_for(:post,).merge(photo_delete_params)
        patch post_path(id: post_with_photo.id), params: { post: post_params },
                                                 headers: turbo_stream
        expect(response.body).to include "写真は1枚以上選択してください"
      end
    end

    context "ログインユーザーが投稿の作成者でない場合" do
      it "失敗すること" do
        other_user = create(:user)
        post_params = attributes_for(:post, :with_photo, title: "Edited Title")

        sign_out user
        sign_in other_user

        patch post_path(id: post_with_photo.id), params: { post: post_params }
        expect(response).to redirect_to posts_path
      end
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete post_path(id: post_with_photo.id)
      expect(response).to redirect_to posts_path
    end

    it "ログインユーザーが投稿の作成者でない場合、失敗すること" do
      other_user = create(:user)
      post_params = attributes_for(:post, :with_photo, title: "Edited Title")

      sign_out user
      sign_in other_user

      delete post_path(id: post_with_photo.id)
      expect(response).to redirect_to posts_path
    end
  end
end
