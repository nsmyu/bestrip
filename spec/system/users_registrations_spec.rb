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

    context "有効な値の場合" do
      it "成功すること" do
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
    end

    context "無効な値の場合" do
      it "現在のパスワードが間違っている場合、失敗すること" do
        fill_in "現在のパスワード", with: "wrongpassword"
        fill_in "新しいパスワード", match: :first, with: "newpassword"
        fill_in "新しいパスワード（確認用）", with: "newpassword"
        click_button "変更する"

        aggregate_failures do
          expect(page).to have_content("パスワードの変更")
          expect(page).to have_content("現在のパスワードが間違っています")
        end
      end

      it "新しいパスワードが5文字以下の場合、失敗すること" do
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

      it "新しいパスワードに半角英数字以外が含まれる場合、失敗すること" do
        fill_in "現在のパスワード", with: user.password
        fill_in "新しいパスワード", match: :first, with: "invalid_password"
        fill_in "新しいパスワード（確認用）", with: "invalid_password"
        click_button "変更する"

        aggregate_failures do
          expect(page).to have_content("パスワードの変更")
          expect(page).to have_content("パスワードは半角英数字で入力してください")
        end
      end
    end
  end

  describe "メールアドレス変更" do
    let(:user) { create(:user) }

    before do
      sign_in user
      visit users_edit_email_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        fill_in "メールアドレス", with: "new_email_address@example.com"
        click_button "変更する"

        expect(current_path).to eq root_path

        visit users_edit_email_path
        expect(page).to have_xpath "//input[@value='new_email_address@example.com']"
      end
    end

    context "無効な値の場合" do
      it "空欄の場合、失敗すること" do
        fill_in "メールアドレス", with: ""
        click_button "変更する"

        aggregate_failures do
          expect(page).to have_content("メールアドレスの変更")
          expect(page).to have_content("メールアドレスを入力してください")
        end
      end

      it "形式が正しくない場合、失敗すること" do
        fill_in "メールアドレス", with: "invalid_email_address"
        click_button "変更する"

        aggregate_failures do
          expect(page).to have_content("メールアドレスの変更")
          # expect(page).to have_content("メールアドレスを入力してください")
        end
      end
    end
  end
end
