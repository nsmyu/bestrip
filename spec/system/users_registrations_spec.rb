require "rails_helper"

RSpec.describe "UsersRegistrations", type: :system do
  describe "新規アカウント登録" do
    let(:user) { build(:user) }

    before do
      visit new_user_registration_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          fill_in "user[name]", with: user.name
          fill_in "user[email]", with: user.email
          fill_in "user[password]", match: :first, with: user.password
          fill_in "user[password_confirmation]", with: user.password_confirmation
          click_button "新規登録"

          expect(page).to have_content "アカウント登録が完了しました。"
          within "header" do
            expect(page).to have_content user.name
          end
          expect(current_path).to eq itineraries_path
        }.to change(User, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "失敗すること" do
        expect {
          fill_in "user[name]", with: ""
          fill_in "user[email]", with: "invalid_email_address"
          fill_in "user[password]", match: :first, with: "foo"
          fill_in "user[password_confirmation]", with: "bar"
          click_button "新規登録"

          expect(page).to have_content "ニックネームを入力してください"
          expect(page).to have_content "メールアドレスを正しく入力してください"
          expect(page).to have_content "パスワードは6文字以上で入力してください"
          expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
        }.not_to change(User, :count)
      end
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

        expect(page).to have_content "パスワードを変更しました。"
        expect(current_path).to eq edit_user_registration_path

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

        sign_out user
        visit new_user_session_path
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "newpassword"
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
      end

      it "確認用パスワードが一致しない場合、失敗すること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", match: :first, with: "newpassword"
        fill_in "user[password_confirmation]", with: "passwordnew"
        click_button "変更する"

        expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"

        sign_out user
        visit new_user_session_path
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "newpassword"
        click_button "ログイン"

        expect(page).to have_content "メールアドレスまたはパスワードが違います。"
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

        expect(page).to have_content "メールアドレスを変更しました。"
        expect(user.reload.email).to eq "new_email@example.com"
        expect(current_path).to eq users_edit_email_path
      end
    end

    context "無効な値の場合" do
      it "メールアドレスが他のユーザーと重複している場合、失敗すること" do
        other_user = create(:user, email: "other_user@example.com")
        fill_in "user[email]", with: other_user.email
        click_button "変更する"

        expect(page).to have_content "メールアドレスを入力してください"
        expect(user.reload.email).to eq user.email
      end

      it "不正な形式の場合、失敗すること" do
        fill_in "user[email]", with: "invalid_email_address"
        click_button "変更する"

        expect(page).to have_content "メールアドレスを正しく入力してください"
        expect(user.reload.email).to eq user.email
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
      it "アバター画像プレビューの表示及びプロフィール変更に成功すること" do
        expect(page).to have_selector "img[id='image_preview'][src*='default_avatar']"

        image_path = Rails.root.join('spec/fixtures/cat.jpg')
        attach_file 'user[avatar]', image_path, make_visible: true

        expect(page).to have_selector "img[id='image_preview'][src*='data:image']"
        expect(page).not_to have_selector "img[id='image_preview'][src*='default_avatar']"

        fill_in "user[name]", with: "edited name"
        fill_in "user[bestrip_id]", with: "edited_id"
        fill_in "user[introduction]", with: "Edited Introduction."
        click_on "保存する"

        expect(page).to have_content "プロフィールを変更しました。"

        visit user_path(user.id)

        expect(page).to have_selector "img[src*='cat.jpg']"
        expect(page).to have_content "edited name"
        expect(page).to have_content "@edited_id"
        expect(page).to have_content "Edited Introduction."
      end
    end

    context "無効な値の場合" do
      it "ニックネームが空欄の場合、失敗すること" do
        fill_in "user[name]", with: ""
        click_on "保存する"

        expect(page).to have_content "ニックネームを入力してください"
        expect(user.reload.name).to eq user.name
      end

      it "ニックネームが21文字以上の場合、失敗すること" do
        fill_in "user[name]", with: "a" * 21
        click_on "保存する"

        expect(page).to have_content "ニックネームは20文字以内で入力してください"
        expect(user.reload.name).to eq user.name
      end

      it "BesTrip IDが21文字以上の場合、失敗すること" do
        fill_in "user[bestrip_id]", with: "a" * 21
        click_on "保存する"

        expect(page).to have_content "IDは20文字以内で入力してください"
        expect(user.reload.bestrip_id).to eq user.bestrip_id
      end

      it "自己紹介が501文字以上入力されると「保存する」ボタンが無効化されること", js: true do
        fill_in "user[introduction]", with: "a" * 500

        expect(page).to have_content "500/500"
        expect(find("#submit_btn")).not_to be_disabled

        fill_in "user[introduction]", with: "a" * 501, fill_options: { clear: :backspace }

        expect(page).to have_content "501/500"
        expect(find("#submit_btn")).to be_disabled
      end
    end

    describe "BesTrip IDの使用可否チェックボタン", js: true do
      it "入力したIDがユーザー間で一意の場合、使用可能メッセージが表示されること" do
        fill_in "BesTrip ID", with: "user_id"
        click_on "IDが使用可能か確認"

        expect(page).to have_content "このIDは使用できます"
      end

      it "入力したIDがユーザー間で重複している場合、エラーメッセージが表示されること" do
        other_user.bestrip_id = "user_id"
        other_user.save
        fill_in "BesTrip ID", with: "user_id"
        click_on "IDが使用可能か確認"

        expect(page).to have_content "このIDは他の人が使用しています"
      end
    end
  end
end
