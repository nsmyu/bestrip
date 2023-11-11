require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper, focus: true  do
  let(:user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }

  describe "#full_title(page_title)", focus: true do
    context '引数が渡されている場合' do
      it "「引数 | Bestrip」を返すこと" do
        expect(helper.full_title("タイトル"))
          .to eq "タイトル | BesTrip"
      end
    end

    context '引数が渡されていない、または空欄およびnilの場合' do
      it "「BesTrip」を返すこと" do
        expect(helper.full_title("")).to eq "BesTrip"
        expect(helper.full_title(" ")).to eq "BesTrip"
        expect(helper.full_title(nil)).to eq "BesTrip"
      end
    end
  end
end
