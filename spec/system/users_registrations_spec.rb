require "rails_helper"

RSpec.describe "UsersRegistrations", type: :system do
  let(:user) { build(:user) }

  scenario "新規アカウント登録" do
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

  scenario "新規アカウント登録失敗" do
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
