require 'rails_helper'

RSpec.describe Itinerary, type: :model do
  describe "バリデーション" do
    it "タイトル、出発日、帰宅日があり、user_id(owner)があれば有効であること" do
      expect(create(:itinerary)).to be_valid
    end

    it "タイトルがなければ無効であること" do
      itinerary = build(:itinerary, title: nil)
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:title, :blank)
    end

    it "タイトルは30文字以下であれば有効であること" do
      expect(create(:itinerary, title: "a" * 30)).to be_valid
    end

    it "タイトルが31文字以上の場合は無効であること" do
      itinerary = build(:itinerary, title: "a" * 31)
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:title, :too_long)
    end

    it "出発日がなければ無効であること" do
      itinerary = build(:itinerary, departure_date: nil)
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:departure_date, :blank)
    end

    it "帰宅日がなければ無効であること" do
      itinerary = build(:itinerary, return_date: nil)
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:return_date, :blank)
    end

    it "帰宅日が出発日より前の場合は無効であること" do
      itinerary = build(:itinerary, departure_date: "2024-03-04", return_date: "2024-03-01")
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:return_date, "は出発日以降で選択してください")
    end

    it "user_id(owner)がなければ無効であること" do
      itinerary = build(:itinerary, owner: nil)
      itinerary.valid?
      expect(itinerary.errors).to be_of_kind(:owner, :blank)
    end
  end

  describe "子モデルのレコード削除" do
    let!(:itinerary) { create(:itinerary, :with_schedule) }

    it "itineraryを削除するとuserとの関連付けのレコードも削除されること" do
      expect { itinerary.destroy }.to change { ItineraryUser.count }.by(-1)
    end

    it "itineraryを削除すると関連するscheduleも削除されること" do
      expect { itinerary.destroy }.to change { Schedule.count }.by(-1)
    end

    it "itineraryを削除すると関連するpostも削除されること" do
      create(:post, :with_photo, itinerary: itinerary)
      expect { itinerary.destroy }.to change { Post.count }.by(-1)
    end

    it "itineraryを削除すると関連するplaceも削除されること" do
      create(:itinerary_place, placeable: itinerary)
      expect { itinerary.destroy }.to change { Place.count }.by(-1)
    end

    it "itineraryを削除すると関連するinvitationも削除されること" do
      create(:invitation, itinerary: itinerary)
      expect { itinerary.destroy }.to change { Invitation.count }.by(-1)
    end
  end
end
