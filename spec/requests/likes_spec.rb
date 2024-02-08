require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: other_user) }
  let(:test_post) { create(:post, :with_photo, itinerary: itinerary) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  # describe "GET /index" do
  #   it "returns http success" do
  #     get "/likes/index"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe "POST #create" do
    it "成功すること" do
      post likes_path(test_post.id), params: { user_id: user.id }
      expect(response.body).to include "お気に入りに追加済み"
    end
  end

  # describe "GET /destroy" do
  #   it "returns http success" do
  #     get "/likes/destroy"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
