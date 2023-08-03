require 'rails_helper'

RSpec.describe "UsersSessions", type: :system do
  let(:user) { create(:user) }

  before do
    visit new_user_session_path
  end

  describe "ログイン" do
    context '有効な値の場合' do
      it "ログインに成功する" do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        click_button "ログイン"

        expect(current_path).to eq root_path
        expect(page).not_to have_selector '.alert-danger'
        expect(page).not_to have_selector "a[href=\"#{new_user_session_path}\"]"
        expect(page).to have_selector "a[href=\"#{destroy_user_session_path}\"]"
      end
    end

    context '無効な値の場合' do
      it 'メールアドレスとパスワードが空欄の場合、失敗すること' do
        fill_in "user[email]", with: ""
        fill_in "user[password]", with: ""
        click_button "ログイン"

        expect(current_path).to eq new_user_session_path
        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end

      it 'メールアドレスは正しいがパスワードが間違っている場合、失敗すること' do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "wrongpassword"
        click_button "ログイン"

        expect(current_path).to eq new_user_session_path
        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end
    end
  end

  describe "ログアウト" do
    it 'ログアウトに成功すること' do
      sign_in user
      visit root_path # あとで修正
      first(:link, 'ログアウト').click

      expect(current_path).to eq root_path
      expect(page).to have_selector "a[href=\"#{new_user_session_path}\"]"
      expect(page).not_to have_selector "a[href=\"#{destroy_user_session_path}\"]"
    end
  end
end
