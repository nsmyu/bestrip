require 'rails_helper'

RSpec.describe ItinerariesHelper, type: :helper do
  let(:user) { create(:user) }
  let(:other_user_1) { create(:user) }
  let(:other_user_2) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }

  describe "#member_names(itinerary)" do
    it "引数のitineraryに関連付けられたユーザーのニックネームを文字列にして返すこと" do
      itinerary.members << other_user_1 << other_user_2
      expect(helper.member_names(itinerary))
        .to eq "#{user.name}, #{other_user_1.name}, #{other_user_2.name}"
    end
  end
end
