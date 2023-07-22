require "rails_helper"

RSpec.describe "UsersRegistrations", type: :system do
  describe "新規アカウント登録" do
    let(:user) { build(:user) }

    it "有効な値の場合、成功すること" do
      expect {
        visit new_user_registration_path
        fill_in "ニックネーム", with: user.name
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", match: :first, with: user.password
        fill_in "パスワード（確認用）", with: user.password_confirmation
        click_button "新規登録"

        expect(current_path).to eq root_path

        aggregate_failures do
          # expect(page).to have_content "登録完了"
          # within ".navbar" do
          #   expect(page).to have_content user.name
          # end
        end
      }.to change(User, :count).by(1)
    end

    it "無効な値の場合、失敗すること" do
      expect {
        visit new_user_registration_path
        fill_in "ニックネーム", with: ""
        fill_in "メールアドレス", with: "invalid.email"
        fill_in "パスワード", match: :first, with: "foo"
        fill_in "パスワード（確認用）", with: "bar"
        click_button "新規登録"

        aggregate_failures do
          expect(page).to have_content("アカウント登録")
          expect(page).to have_content("メールアドレスは不正な値です")
          expect(page).to have_content("パスワードは6文字以上で入力してください")
          expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
          within ".navbar" do
            expect(page).not_to have_content user.name
          end
        end
      }.not_to change(User, :count)
    end
  end

  describe "パスワード変更" do
    let(:user) { create(:user) }

    before do
      sign_in user
      visit users_edit_password_path
    end

    it "有効な値の場合、成功すること" do
      fill_in "現在のパスワード", with: user.password
      fill_in "新しいパスワード", match: :first, with: "newpassword"
      fill_in "新しいパスワード（確認用）", with: "newpassword"
      click_button "変更する"

      expect(current_path).to eq root_path

      sign_out user
      visit new_user_session_path
      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "newpassword"
      click_button "ログイン"

      expect(current_path).to eq root_path
      expect(page).not_to have_selector '.alert-notice', text: "ログインしました。"
    end

    it "現在のパスワードが間違っている場合、失敗すること" do
      fill_in "現在のパスワード", with: "wrongpassword"
      fill_in "新しいパスワード", match: :first, with: "newpassword"
      fill_in "新しいパスワード（確認用）", with: "newpassword"
      click_button "変更する"

      aggregate_failures do
        expect(page).to have_content("パスワードの変更")
        expect(page).to have_content("現在のパスワードは不正な値です")
      end
    end

    it "新しいパスワードが無効な値の場合、失敗すること" do
      fill_in "現在のパスワード", with: user.password
      fill_in "新しいパスワード", match: :first, with: "foo"
      fill_in "新しいパスワード（確認用）", with: "bar"
      click_button "変更する"

      aggregate_failures do
        expect(page).to have_content("パスワードの変更")
        expect(page).to have_content("パスワードは6文字以上で入力してください")
        expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
      end
    end
  end
end
