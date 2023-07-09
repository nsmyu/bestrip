require 'rails_helper'

RSpec.describe "UsersSessions", type: :request do

  let(:user) { build(:user) }

  describe "GET /users_sessions" do
    it "ログイン画面の表示に成功すること" do
      get new_user_session_path
      expect(response).to have_http_status(200)
    end
  end

  # describe "POST /users_sessions" do
  #   it "ログインに成功すること" do
  #     post new_user_session_path, params: { user: user }
  #     expect(response).to have_http_status(200)
  #   end
  # end
end
