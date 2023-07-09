require 'rails_helper'

RSpec.describe "UsersSessions", type: :system do

  let(:user) { create(:user) }

  scenario "正しいメールアドレスとパスワードでログイン" do
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(current_path).to eq root_path

      aggregate_failures do
        # expect(page).to have_content "登録完了"
        # within ".navbar" do
        #   expect(page).to have_content user.name
        # end
      end
  end

  scenario "正しいメールアドレス、間違ったパスワードでログイン" do
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "wrongpassword"
    click_button "ログイン"

    expect(current_path).to eq new_user_session_path

    # aggregate_failures do
    #   expect(page).to have_content("アカウント登録")
    #   expect(page).to have_content("メールアドレスは不正な値です")
    #   expect(page).to have_content("パスワードは6文字以上で入力してください")
    #   expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
    #   within ".navbar" do
    #     expect(page).not_to have_content user.name
    #   end
    # end
  end

  scenario "ログイン失敗" do
    visit new_user_session_path
    fill_in "メールアドレス", with: ""
    fill_in "パスワード", with: ""
    click_button "ログイン"

    expect(current_path).to eq new_user_session_path

    # aggregate_failures do
    #   expect(page).to have_content("アカウント登録")
    #   expect(page).to have_content("メールアドレスは不正な値です")
    #   expect(page).to have_content("パスワードは6文字以上で入力してください")
    #   expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
    #   within ".navbar" do
    #     expect(page).not_to have_content user.name
    #   end
    # end
  end
end
