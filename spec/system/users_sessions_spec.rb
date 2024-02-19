require 'rails_helper'

RSpec.describe "UsersSessions", type: :system, focus: true do
  let!(:user) { create(:user) }

  before do
    visit new_user_session_path
  end

  describe "ログイン" do
    context '有効な値の場合' do
      it "成功すること" do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        click_button "ログイン"

        expect(page).to have_content "ログインしました。"
        within "header" do
          expect(page).to have_content user.name
          expect(page).to have_link "ログアウト", href: "/users/sign_out"
        end
        expect(current_path).to eq itineraries_path
      end
    end

    context '無効な値の場合' do
      it 'メールアドレスが間違っている場合、失敗すること' do
        fill_in "user[email]", with: "wrong@example.com"
        fill_in "user[password]", with: user.password
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        expect(current_path).to eq new_user_session_path
      end

      it 'パスワードが間違っている場合、失敗すること' do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "wrongpassword"
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "ログアウト" do
    it 'ヘッダーのドロップダウンメニューからログアウトに成功すること', js: true do
      sign_in user
      visit itineraries_path
      within "header" do
        find("p", text: user.name).hover
        click_on "ログアウト"
      end

      expect(page).to have_content "ログアウトしました。"
      within "header" do
        expect(page).not_to have_content user.name
        expect(page).to have_link "ログイン", href: "/users/sign_in"
      end
      expect(current_path).to eq root_path
    end

    it 'サイドバーのリンクからログアウトに成功すること' do
      sign_in user
      visit users_edit_email_path
      within ".sidenav" do
        click_on "ログアウト"
      end

      expect(page).to have_content "ログアウトしました。"
      within "header" do
        expect(page).not_to have_content user.name
        expect(page).to have_link "ログイン", href: "/users/sign_in"
      end
      expect(current_path).to eq root_path
    end
  end
end
