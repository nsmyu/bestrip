require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  describe "#invitation_instructions" do
    let(:user) { create(:user) }
    let(:invitee) { create(:user) }
    let(:itinerary) { create(:itinerary) }
    let(:invitation_token) { Devise.token_generator.generate(User, :invitation_token) }
    let(:mail) { described_class.invitation_instructions(invitee, invitation_token[0]) }

    before do
      invitee.send("currently_invited_to=", itinerary.id)
      invitee.update(invited_by_id: user.id)
      mail
    end

    it "ヘッダー情報が正しいこと" do
      expect(mail.subject).to eq "#{user.name}さんがあなたを旅のメンバーに招待しています"
      expect(mail.to).to eq [invitee.email]
      expect(mail.from).to eq ["bestrip2024@gmail.com"]
    end

    it "本文に旅のプランの情報が含まれていること" do
      mail.deliver_now
      last_mail = ActionMailer::Base.deliveries.last
      expect(last_mail.html_part.body.to_s).to include itinerary.title
      expect(last_mail.html_part.body.to_s).to include I18n.l itinerary.departure_date
      expect(last_mail.html_part.body.to_s).to include I18n.l itinerary.return_date
    end

    it "本文にinvitation承認用のリンクが記載されていること" do
      mail.deliver_now
      last_mail = ActionMailer::Base.deliveries.last
      expect(last_mail.html_part.body.to_s)
        .to include "http://example.com/users/invitation/accept?invitation_token=#{invitation_token[0]}&amp;itinerary_id=#{itinerary.id}"
    end
  end
end
