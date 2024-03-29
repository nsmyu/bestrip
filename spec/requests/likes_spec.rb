require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:test_post) { create(:post, :with_photo) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "POST #create" do
    it "成功すること" do
      post likes_path(test_post.id), headers: turbo_stream
      expect(test_post.reload.likes.count).to eq 1
    end
  end

  describe "GET #destroy" do
    it "成功すること" do
      create(:like, post: test_post, user: user)
      delete like_path(test_post.id), headers: turbo_stream
      expect(test_post.reload.likes.count).to eq 0
    end
  end
end
