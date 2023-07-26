require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "ニックネーム、メールアドレス、パスワード、一致する確認用パスワードあれば有効であること" do
      user = User.new(
        name: "Conan",
        email: "edogawa@example.com",
        password: "password1",
        password_confirmation: "password1",
      )
      user.valid?
      expect(user).to be_valid
    end

    it "ニックネームがなければ無効であること" do
      user = build(:user, name: nil)
      user.valid?
      expect(user.errors).to be_of_kind(:name, :blank)
    end

    it "ニックネームが51文字以上の場合は無効であること" do
      user = build(:user, name: "a" * 51)
      user.valid?
      expect(user.errors).to be_of_kind(:name, :too_long)
    end

    it "BesTrip IDが重複している場合は無効であること" do
      create(:user, bestrip_id: "shinichi_kudo")
      other_user = build(:user, bestrip_id: "shinichi_kudo")
      other_user.valid?
      expect(other_user.errors).to be_of_kind(:bestrip_id, :taken)
    end

    it "BesTrip IDが21文字以上の場合は無効であること" do
      user = build(:user, bestrip_id: "a" * 21)
      user.valid?
      expect(user.errors).to be_of_kind(:bestrip_id, :too_long)
    end

    it "BesTrip IDに半角英数字、アンダースコア以外は使用できないこと" do
      user = build(:user, bestrip_id: "invlid-id")
      user.valid?
      expect(user.errors).to be_of_kind(:bestrip_id, :invalid)
    end

    it "メールアドレスがなければ無効であること" do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors).to be_of_kind(:email, :blank)
    end

    it "メールアドレスが他のユーザーと重複している場合は無効であること" do
      create(:user)
      user = build(:user, email: "edogawa@example.com")
      user.valid?
      expect(user.errors).to be_of_kind(:email, :taken)
    end

    it "メールアドレスが不正な形式の場合は無効であること" do
      user = build(:user, email: "edogawa")
      user.valid?
      expect(user.errors).to be_of_kind(:email, :invalid)
    end

    it "パスワードがなければ無効であること" do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors).to be_of_kind(:password, :blank)
    end

    it "パスワードが5文字以下の場合は無効であること" do
      user = build(:user, password: "a" * 5)
      user.valid?
      expect(user.errors).to be_of_kind(:password, :too_short)
    end

    it "パスワードが129文字以上の場合は無効であること" do
      user = build(:user, password: "a" * 129)
      user.valid?
      expect(user.errors).to be_of_kind(:password, :too_long)
    end

    it "パスワードに半角英数字以外は使用できないこと" do
      user = build(:user, password: "invalid-password")
      user.valid?
      expect(user.errors).to be_of_kind(:password, :invalid)
    end

    it "確認用パスワードが一致しない場合は無効であること" do
      user = build(:user, password_confirmation: "wrongpassword")
      user.valid?
      expect(user.errors).to be_of_kind(:password_confirmation, :confirmation)
    end
  end
end
