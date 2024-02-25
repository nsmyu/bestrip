require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper, focus: true do
  describe "#full_title(page_title)" do
    it "引数が渡された場合、「引数 | Bestrip」を返すこと" do
      expect(helper.full_title("タイトル")).to eq "タイトル | BesTrip"
    end

    it "引数が空欄、空白およびnilの場合、「BesTrip」を返すこと" do
      expect(helper.full_title("")).to eq "BesTrip"
      expect(helper.full_title(" ")).to eq "BesTrip"
      expect(helper.full_title(nil)).to eq "BesTrip"
    end
  end

  describe "#ogp_image(itinerary_image)" do
    it "引数に画像の相対パスが渡された場合、その画像の絶対パスを返すこと" do
      itinerary = create(:itinerary, :with_image)
      expect(helper.ogp_image(itinerary.image.url))
        .to eq "https://s3.ap-northeast-1.amazonaws.com/bestrip#{itinerary.image.url}"
    end

    it "引数にitineraryのデフォルト画像の相対パスが渡された場合、デフォルト画像の絶対バスを返すこと" do
      expect(helper.ogp_image("default_itinerary.jpg"))
        .to eq "https://bestrip.s3.ap-northeast-1.amazonaws.com/uploads/default_ogp_image.png"
    end
  end
end
