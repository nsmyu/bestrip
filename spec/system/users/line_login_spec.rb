require 'rails_helper'

RSpec.describe "Users::LineLogins", type: :system do
  let(:user) { create(:user) }
  let(:invitee) { build(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:pending_invitation) { create(:pending_invitation, :with_code, itinerary: itinerary) }

  describe "旅のプランへの招待をLINEで送信" do
    it "LINEアイコンクリック時にpending_invitationのデータが作成されること" do
      sign_in user
      visit itinerary_path(itinerary.id)
      expect { find("#line_invitation_btn", visible: false).click }
        .to change { itinerary.pending_invitations.count }.by(1)
    end
  end

  describe "招待LINEから旅のプランに参加" do
    it "ログイン開始前の画面で、招待されているプランの情報を表示すること" do
      visit line_login_new_path(invitation_code: pending_invitation.code)
      expect(page).to have_content itinerary.title
      expect(page).to have_content I18n.l itinerary.departure_date
      expect(page).to have_content I18n.l itinerary.return_date
    end

    it "メールアドレスでアカウント登録後、招待の承認に成功すること（LINEアカウントにメールアドレスが無い場合）", js: true do
      visit line_login_new_path(invitation_code: pending_invitation.code)
      expect do
        fill_in "user[name]", with: invitee.name
        fill_in "user[email]", with: invitee.email
        fill_in "user[password]", with: invitee.password
        fill_in "user[password_confirmation]", with: invitee.password_confirmation
        find("input.btn").click

        sleep 0.5
        expect(current_path).to eq itineraries_path

        click_on "この旅のプランに参加する"

        expect(page).to have_content "旅のプランに参加しました。"
        expect(page).to have_content I18n.l itinerary.departure_date
      end
        .to change { itinerary.members.count }.by(1)
        .and change { PendingInvitation.count }.by(-1)
    end
  end
end
