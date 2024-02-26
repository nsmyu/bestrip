require 'rails_helper'

RSpec.describe "Users::LineLogin", type: :request do
  let(:itinerary) { create(:itinerary) }
  let(:pending_invitation) { create(:pending_invitation, :with_code, itinerary: itinerary) }

  describe "GET #new" do
    it "正常にレスポンスを返すこと" do
      get line_login_new_path(invitation_code: pending_invitation.code)
      expect(response).to have_http_status 200
    end

    it "招待された旅のプランの情報を取得すること" do
      get line_login_new_path(invitation_code: pending_invitation.code)
      expect(response.body).to include itinerary.title
      expect(response.body).to include I18n.l itinerary.departure_date
      expect(response.body).to include I18n.l itinerary.return_date
    end
  end

  describe "GET #login" do
    it "LINEログインの認証URLにリダイレクトされること" do
      get line_login_login_path(invitation_code: pending_invitation.code)
      expect(response).to have_http_status 302
      expect(response.body).to include "https://access.line.me/oauth2/v2.1/authorize"
    end
  end
end
