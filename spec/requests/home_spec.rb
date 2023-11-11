require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET #guide" do
    it "正常にレスポンスを返すこと" do
      get guide_path
      expect(response).to have_http_status 200
    end
  end
end
