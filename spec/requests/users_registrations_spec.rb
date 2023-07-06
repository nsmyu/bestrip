require 'rails_helper'

RSpec.describe "UsersRegistrations", type: :request do
  describe "GET /users_registrations_new" do
    it "正常にレスポンスを返すこと" do
      get new_user_registration_path
      expect(response).to have_http_status(200)
    end
  end
end
