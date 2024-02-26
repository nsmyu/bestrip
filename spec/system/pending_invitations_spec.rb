require "rails_helper"

RSpec.describe "PendingInvitations", type: :system do
  describe "旅のプラン一覧ページで招待通知に応答" do
    let(:invitee) { create(:user) }
    let(:itinerary_1) { create(:itinerary) }
    let(:itinerary_2) { create(:itinerary) }

    before do
      sign_in invitee
      create(:pending_invitation, user: invitee, itinerary: itinerary_1)
      create(:pending_invitation, user: invitee, itinerary: itinerary_2)
      visit itineraries_path
    end

    it "旅のプランへの招待通知を招待された日時の昇順で表示されること" do
      expect(page.text)
        .to match(/「#{itinerary_1.title}」に招待されています[\s\S]*「#{itinerary_2.title}」に招待されています/)
    end

    it "プランへの参加に成功すること", js: true do
      expect do
        click_on "「#{itinerary_1.title}」に招待されています"
        click_on "この旅のプランに参加する"

        expect(page).not_to have_content "「#{itinerary_1.title}」に招待されています"
        expect(page).to have_content "旅のプランに参加しました。"
        expect(page).to have_content I18n.l itinerary_1.departure_date
        expect(current_path).to eq itineraries_path
      end
        .to change { itinerary_1.members.count }.by(1)
        .and change { PendingInvitation.count }.by(-1)
    end

    it "招待の削除に成功すること", js: true do
      expect do
        click_on "「#{itinerary_1.title}」に招待されています"
        within ".dropdown-center" do
          find("span", text: "参加しない（招待を削除）").click
          click_on "削除する"
        end

        expect(page).not_to have_content "「#{itinerary_1.title}」に招待されています"
        expect(page).not_to have_content I18n.l itinerary_1.departure_date
        expect(page).to have_content "「#{itinerary_1.title}」への招待を削除しました。"
        expect(current_path).to eq itineraries_path
      end
        .to not_change { itinerary_1.members.count }
        .and change { PendingInvitation.count }.by(-1)
    end
  end
end
