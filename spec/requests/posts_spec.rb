require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:post_with_photo) { create(:post, :with_photo, itinerary: itinerary) }
  let(:photo) { build(:photo) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "正常にレスポンスを返すこと" do
      get posts_path
      expect(response).to have_http_status 200
    end

    # it "旅のプランに含まれるスケジュールを全て取得すること" do
    #   post1 = create(:post, :with_photo,itinerary_id: itinerary.id)
    #   post2 = create(:post, :with_photo,itinerary_id: itinerary.id)
    #   get itinerary_posts_path
    #   expect(response.body).to include post1.title, post2.title
    # end

    # it "スケジュールのタイトル、日付、開始・終了時間を取得すること" do
    #   post = create(:post, :with_photo,itinerary_id: itinerary.id)
    #   get itinerary_posts_path
    #   expect(response.body).to include post.title
    #   expect(response.body).to include I18n.l post.post_date
    #   expect(response.body).to include I18n.l post.start_at
    #   expect(response.body).to include I18n.l post.end_at
    # end
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
        expect(response).to redirect_to posts_path
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

  # describe "GET #show" do
  #   before do
  #     get post_path(id: post.id)
  #   end

  #   it "正常にレスポンスを返すこと" do
  #     expect(response).to have_http_status 200
  #   end

  #   # it "スケジュールの情報を取得すること" do
  #   #   expect(response.body).to include post.title
  #   #   expect(response.body).to include post.note
  #   # end
  # end

  describe "GET #edit" do
    before do
      get edit_post_path(id: post_with_photo.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "投稿の内容を取得すること" do
      expect(response.body).to include post_with_photo.title
      expect(response.body).to include post_with_photo.caption
      expect(response.body).to include post_with_photo.itinerary.title
    end
  end

  describe "PATCH #update" do
    context "有効な値の場合" do
      it "各項目の変更に成功すること" do
        other_itinerary = create(:itinerary, owner: user)
        post_params = attributes_for(:post, :with_photo, title: "New Title",
                                                         caption: "New caption.",
                                                         itinerary_id: other_itinerary.id)
        patch post_path(id: post_with_photo.id), params: { post: post_params }
        expect(response).to redirect_to posts_path
        expect(post_with_photo.reload.title).to eq "New Title"
        expect(post_with_photo.reload.caption).to eq "New caption."
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
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      delete post_path(id: post_with_photo.id)
      expect(response).to redirect_to posts_path
    end
  end
end
