require "rails_helper"

RSpec.describe ItineraryUser, type: :model do
  describe "バリデーション" do
    it "user_id、itinerary_idがあれば有効であること" do
      expect(build(:itinerary_user)).to be_valid
    end

    it "user_idがなければ無効であること" do
      itinerary_users = build(:itinerary_user, user: nil)
      itinerary_users.valid?
      expect(itinerary_users.errors).to be_of_kind(:user, :blank)
    end

    it "itinerary_idがなければ無効であること" do
      itinerary_users = build(:itinerary_user, itinerary: nil)
      itinerary_users.valid?
      expect(itinerary_users.errors).to be_of_kind(:itinerary, :blank)
    end

    it "confirmedがnilの場合は無効であること" do
      itinerary_users = build(:itinerary_user, confirmed: nil)
      itinerary_users.valid?
      expect(itinerary_users.errors).to be_of_kind(:confirmed, :blank)
    end

    it "userとitineraryの組み合わせが一意でない場合、無効であること" do
      itinerary = create(:itinerary)
      user = create(:user)
      create(:itinerary_user, user: user, itinerary: itinerary)
      itinerary_user = build(:itinerary_user, user: user, itinerary: itinerary)
      itinerary_user.valid?
      expect(itinerary_user.errors).to be_of_kind(:user, :taken)
    end
  end
end
