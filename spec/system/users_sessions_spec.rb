require 'rails_helper'

RSpec.describe "UsersSessions", type: :system do
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

        expect(current_path).to eq itineraries_path
        expect(page).to have_content "ログインしました。"
        within "header" do
          expect(page).to have_content user.name
        end
      end
    end

    context '無効な値の場合' do
      it 'メールアドレスとパスワードが空欄の場合、失敗すること' do
        fill_in "user[email]", with: ""
        fill_in "user[password]", with: ""
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end

      it 'メールアドレスが間違っている場合、失敗すること' do
        fill_in "user[email]", with: "wrong_email@example.com"
        fill_in "user[password]", with: user.password
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end

      it 'パスワードが間違っている場合、失敗すること' do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "wrongpassword"
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end
    end
  end

  describe "ログアウト" do
    it '成功すること' do
      sign_in user
      visit itineraries_path
      first(:link, 'ログアウト').click

      expect(page).to have_content "ログアウトしました。"
      expect(current_path).to eq root_path
      within "header" do
        expect(page).not_to have_content user.name
      end
    end
  end
end
