require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

  describe "GET #show" do
    before do
      get user_path(id: user.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "ユーザーのプロフィール情報を取得すること" do
      expect(response.body).to include user.name
      expect(response.body).to include user.bestrip_id
      expect(response.body).to include user.introduction
    end

    it "ユーザーの投稿を取得すること" do
      expect(response.body).to include post.title
    end
  end
end
