require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }

  describe "#full_title(page_title)" do
    context '個別のページタイトルが設定されていない場合' do
      it "「BesTrip」を返すこと" do
        expect(helper.full_title("")).to eq "BesTrip"
        expect(helper.full_title(" ")).to eq "BesTrip"
        expect(helper.full_title(nil)).to eq "BesTrip"
      end
    end

    context '個別のページタイトルが設定されている場合', focus: true do
      it "「個別のページタイトル | potepanec」を返すこと" do
        expect(helper.full_title(itinerary.title + " - 旅のプラン情報"))
          .to eq "#{itinerary.title + " - 旅のプラン情報"} | BesTrip"
      end
    end
  end
end
