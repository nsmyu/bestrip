require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title(page_title)" do
    context '引数が渡されている場合' do
      it "「引数 | Bestrip」を返すこと" do
        expect(helper.full_title("タイトル")).to eq "タイトル | BesTrip"
      end
    end

    context '引数が空欄、空白およびnilの場合' do
      it "「BesTrip」を返すこと" do
        expect(helper.full_title("")).to eq "BesTrip"
        expect(helper.full_title(" ")).to eq "BesTrip"
        expect(helper.full_title(nil)).to eq "BesTrip"
      end
    end
  end
end
