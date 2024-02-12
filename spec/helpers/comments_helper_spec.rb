require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  let(:now) { Time.current }

  describe "#time_since_creation(created_at)" do
    it "引数に現在時刻から1分前未満の時刻が与えられた場合、「たった今」を返すこと" do
      expect(helper.time_since_creation(now - 59.seconds)).to eq "たった今"
    end

    it "引数に現在時刻から1時間前未満の時刻が与えられた場合、「⚪︎分前」を返すこと" do
      expect(helper.time_since_creation(now - 59.minutes)).to eq "59分前"
    end

    it "引数に現在時刻から24時間前未満の時刻が与えられた場合、「⚪︎時間前」を返すこと" do
      expect(helper.time_since_creation(now - 23.hours)).to eq "23時間前"
    end

    it "引数に現在時刻から7日前未満の時刻が与えられた場合、「⚪︎日前」を返すこと" do
      expect(helper.time_since_creation(now - 6.days)).to eq "6日前"
    end

    it "引数に現在時刻から7日前以上の時刻が与えられた場合、「⚪︎週間前」を返すこと" do
      expect(helper.time_since_creation(now - 1.week)).to eq "1週間前"
    end
  end
end
