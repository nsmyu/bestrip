require 'rails_helper'

RSpec.describe User, type: :model do
  it "ニックネーム、メールアドレス、パスワード、一致する確認用パスワードあれば有効であること" do
    expect(build(:user, bestrip_id: nil, introduction: nil)).to be_valid
  end

  it "ニックネームがなければ無効であること" do
    user = build(:user, name: nil)
    user.valid?
    expect(user.errors).to be_of_kind(:name, :blank)
  end

  it "ニックネームは20文字以下であれば有効であること" do
    expect(build(:user, name: "a" * 20)).to be_valid
  end

  it "ニックネームが21文字以上の場合は無効であること" do
    user = build(:user, name: "a" * 21)
    user.valid?
    expect(user.errors).to be_of_kind(:name, :too_long)
  end

  it "bestrip_idが4文字以下の場合は無効であること" do
    user = build(:user, bestrip_id: "a" * 4)
    user.valid?
    expect(user.errors).to be_of_kind(:bestrip_id, :too_short)
  end

  it "bestrip_idは5文字以上であれば有効であること" do
    expect(build(:user, bestrip_id: "a" * 5)).to be_valid
  end

  it "bestrip_idは20文字以下であれば有効であること" do
    expect(build(:user, bestrip_id: "a" * 20)).to be_valid
  end

  it "BesTrip IDが21文字以上の場合は無効であること" do
    user = build(:user, bestrip_id: "a" * 21)
    user.valid?
    expect(user.errors).to be_of_kind(:bestrip_id, :too_long)
  end

  it "BesTrip IDが他のユーザーと重複している場合は無効であること" do
    create(:user, bestrip_id: "user_id")
    other_user = build(:user, bestrip_id: "user_id")
    other_user.valid?
    expect(other_user.errors).to be_of_kind(:bestrip_id, :taken)
  end

  it "BesTrip IDに半角英数字、アンダースコア以外を使用している場合は無効であること" do
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
    user = create(:user)
    other_user = build(:user, email: user.email)
    other_user.valid?
    expect(other_user.errors).to be_of_kind(:email, :taken)
  end

  it "メールアドレスが不正な形式の場合は無効であること" do
    user = build(:user, email: "invalid_email_address")
    user.valid?
    expect(user.errors).to be_of_kind(:email, :invalid)
  end

  it "パスワードがなければ無効であること" do
    user = build(:user, password: nil)
    user.valid?
    expect(user.errors).to be_of_kind(:password, :blank)
  end

  it "パスワードが5文字以下の場合は無効であること" do
    user = build(:user, password: "a" * 5, password_confirmation: "a" * 5)
    user.valid?
    expect(user.errors).to be_of_kind(:password, :too_short)
  end

  it "パスワードは6文字以上であれば有効であること" do
    expect(build(:user, password: "a" * 6, password_confirmation: "a" * 6)).to be_valid
  end

  it "パスワードは128文字以下であれば有効であること" do
    expect(build(:user, password: "a" * 128, password_confirmation: "a" * 128)).to be_valid
  end

  it "パスワードが129文字以上の場合は無効であること" do
    user = build(:user, password: "a" * 129, password_confirmation: "a" * 129,)
    user.valid?
    expect(user.errors).to be_of_kind(:password, :too_long)
  end

  it "パスワードに半角英数字以外は使用できないこと" do
    user = build(:user, password: "invalid-password", password_confirmation: "invalid-password")
    user.valid?
    expect(user.errors).to be_of_kind(:password, :invalid)
  end

  it "確認用パスワードが一致しない場合は無効であること" do
    user = build(:user, password_confirmation: "wrongpassword")
    user.valid?
    expect(user.errors).to be_of_kind(:password_confirmation, :confirmation)
  end

  it "自己紹介は500文字以下であれば有効であること" do
    expect(build(:user, introduction: "a" * 500)).to be_valid
  end

  it "自己紹介が501文字以上の場合は無効であること" do
    user = build(:user, introduction: "a" * 501)
    user.valid?
    expect(user.errors).to be_of_kind(:introduction, :too_long)
  end
end
