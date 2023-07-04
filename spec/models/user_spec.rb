require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe "ニックネーム" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe "BesTrip ID" do
    it { is_expected.to validate_uniqueness_of(:bestrip_id).case_insensitive }
    it { is_expected.to validate_length_of(:bestrip_id).is_at_most(50) }
  end

  describe "メールアドレス" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }
  end

  describe "パスワード" do
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6).is_at_most(128) }
  end

  describe "パスワード確認" do
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6).is_at_most(128) }
  end
end
