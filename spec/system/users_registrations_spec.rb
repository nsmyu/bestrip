require "rails_helper"

RSpec.describe "UsersRegistrations", type: :system do
  describe "新規アカウント登録" do
    let(:user) { build(:user) }

    before do
      visit new_user_registration_path
    end

    it "有効な値の場合、成功すること" do
      expect {
        fill_in "user[name]", with: user.name
        fill_in "user[email]", with: user.email
        fill_in "user[password]", match: :first, with: user.password
        fill_in "user[password_confirmation]", with: user.password_confirmation
        click_button "新規登録"

        expect(current_path).to eq itineraries_path
        expect(page).to have_content "アカウント登録が完了しました。"
        within "header" do
          expect(page).to have_content user.name
        end
      }.to change(User, :count).by(1)
    end

    it "必須項目が空欄の場合、失敗すること" do
      expect {
        fill_in "user[name]", with: ""
        fill_in "user[email]", with: ""
        fill_in "user[password]", match: :first, with: ""
        fill_in "user[password_confirmation]", with: ""
        click_button "新規登録"

        expect(page).to have_content "ニックネームを入力してください"
        expect(page).to have_content "メールアドレスを入力してください"
        expect(page).to have_content "パスワードを入力してください"
        expect(page).to have_content "パスワード（確認用）を入力してください"
      }.not_to change(User, :count)
    end

    it "無効な形式の場合、失敗すること" do
      expect {
        fill_in "user[name]", with: user.name
        fill_in "user[email]", with: "invalid.email"
        fill_in "user[password]", match: :first, with: "foo"
        fill_in "user[password_confirmation]", with: "bar"
        click_button "新規登録"

        expect(page).to have_content "メールアドレスを正しく入力してください"
        expect(page).to have_content "パスワードは6文字以上で入力してください"
        expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
      }.not_to change(User, :count)
    end

    it "メールアドレスが重複している場合、失敗すること" do
      user.save
      expect {
        fill_in "user[name]", with: "other_user"
        fill_in "user[email]", with: user.email
        fill_in "user[password]", match: :first, with: "password"
        fill_in "user[password_confirmation]", with: "password"
        click_button "新規登録"

        expect(page).to have_content "このメールアドレスはすでに登録されています"
      }.not_to change(User, :count)
    end
  end

  describe "パスワード変更" do
    let!(:user) { create(:user) }

    before do
      sign_in user
      visit edit_user_registration_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        fill_in "現在のパスワード", with: user.password
        fill_in "user[password]", match: :first, with: "newpassword"
        fill_in "user[password_confirmation]", with: "newpassword"
        click_button "変更する"

        expect(current_path).to eq edit_user_registration_path
        expect(page).to have_content "パスワードを変更しました。"

        sign_out user
        visit new_user_session_path
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "newpassword"
        click_button "ログイン"

        expect(page).to have_content "ログインしました。"
      end
    end

    context "無効な値の場合" do
      it "現在のパスワードが間違っている場合、失敗すること" do
        fill_in "user[current_password]", with: "wrongpassword"
        fill_in "user[password]", match: :first, with: "newpassword"
        fill_in "user[password_confirmation]", with: "newpassword"
        click_button "変更する"

        expect(page).to have_content "現在のパスワードが間違っています"
      end

      it "新しいパスワードが5文字以下の場合、失敗すること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", match: :first, with: "foo"
        fill_in "user[password_confirmation]", with: "bar"
        click_button "変更する"

        expect(page).to have_content "パスワードは6文字以上で入力してください"
        expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
      end

      it "新しいパスワードに半角英数字以外が含まれる場合、失敗すること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", match: :first, with: "invalid_password"
        fill_in "user[password_confirmation]", with: "invalid_password"
        click_button "変更する"

        expect(page).to have_content "パスワードは半角英数字で入力してください"
      end
    end
  end

  describe "メールアドレス変更" do
    let!(:user) { create(:user) }

    before do
      sign_in user
      visit users_edit_email_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        fill_in "user[email]", with: "new_email@example.com"
        click_button "変更する"

        expect(current_path).to eq users_edit_email_path
        expect(page).to have_content "メールアドレスを変更しました。"

        visit users_edit_email_path
        expect(page).to have_xpath "//input[@value='new_email@example.com']"
      end
    end

    context "無効な値の場合" do
      it "空欄の場合、失敗すること" do
        fill_in "user[email]", with: ""
        click_button "変更する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "無効な形式の場合、失敗すること" do
        fill_in "user[email]", with: "invalid_email_address"
        click_button "変更する"

        expect(page).to have_content "メールアドレスを正しく入力してください"
      end
    end
  end

  describe "プロフィールの編集" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      sign_in user
      visit users_edit_profile_path
    end

    context "有効な値の場合", js: true do
      it "成功すること" do
        expect(page).to have_selector "img[src*='default_avatar']"

        image_path = Rails.root.join('spec/fixtures/cat.jpg')
        attach_file 'user[avatar]', image_path, make_visible: true

        within "form" do
          expect(page).not_to have_selector "img[src*='default_avatar']"
        end

        fill_in "user[name]", with: "edited name"
        fill_in "user[bestrip_id]", with: "user_id"
        fill_in "user[introduction]", with: "Introduction of myself."
        click_on "保存する"

        expect(current_path).to eq users_edit_profile_path
        expect(page).to have_content "プロフィールを変更しました。"

        visit user_path(id: user.id)

        expect(page).to have_selector "img[src*='cat.jpg']"
        expect(page).to have_content "edited name"
        expect(page).to have_content "@user_id"
        expect(page).to have_content "Introduction of myself."
      end
    end

    context "無効な値の場合" do
      it "ニックネームが空欄の場合、失敗すること" do
        fill_in "user[name]", with: ""
        click_on "保存する"

        expect(page).to have_content "ニックネームを入力してください"
      end

      it "自己紹介が501文字以上入力された場合、「保存する」ボタンが押せないこと", js: true do
        fill_in "user[introduction]", with: "a" * 500

        expect(page).to have_content "500"
        expect(find("#submit_btn")).not_to be_disabled

        fill_in "user[introduction]", with: "a" * 501

        expect(page).to have_content "501"
        expect(find("#submit_btn")).to be_disabled
      end
    end

    describe "BesTrip IDの使用可否チェックボタン", js: true do
      it "入力したIDがユニークな場合、使用可能メッセージが表示されること" do
        fill_in "BesTrip ID", with: "user_id"
        click_on "IDが使用可能か確認"

        expect(page).to have_content "このIDは使用できます"
      end

      it "入力したIDが重複している場合、エラーメッセージが表示されること" do
        other_user.bestrip_id = "user_id"
        other_user.save
        fill_in "BesTrip ID", with: "user_id"
        click_on "IDが使用可能か確認"

        expect(page).to have_content "このIDは他の人が使用しています"
      end
    end
  end
end
