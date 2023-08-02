require "rails_helper"

RSpec.describe "Itineraries", type: :system do
  describe "旅のプラン新規登録", js: true do
    let(:user) { create(:user) }
    let(:itinerary) { build(:itinerary) }

    before do
      sign_in user
      visit itineraries_path
      click_on "旅のプランを作成"
    end

    it "有効な値の場合、成功すること" do
      expect {
        fill_in "itinerary[title]", with: itinerary.title
        find("#departure-date-pickr").click
        find('div.dayContainer > span:nth-child(1)').click
        find("#return-date-pickr").click
        find('div.dayContainer > span:nth-child(2)').click

        expect(page).to have_selector "img[src*='default_itinerary']"

        image_path = Rails.root.join('spec/fixtures/test_image.jpg')
        attach_file 'itinerary[image]', image_path, make_visible: true

        expect(page).not_to have_selector "img[src*='default_avatar']"

        click_on "保存する"

        aggregate_failures do
          # expect(current_path).to eq root_path
          expect(page).to have_content "新しい旅のプランを作成しました。次はスケジュールを追加してみましょう。"
          # expect(page).to have_content itinerary.title
          # within ".navbar" do
          #   expect(page).to have_content user.name
          # end
        end
      }.to change(Itinerary, :count).by(1)
    end

    it "必須項目が空欄の場合、失敗すること" do
      expect {
        fill_in "itinerary[title]", with: ""
        click_on "保存する"

        aggregate_failures do
          expect(page).to have_content "タイトルを入力してください"
          expect(page).to have_content "出発日を入力してください"
          expect(page).to have_content "帰宅日を入力してください"
        end
      }.not_to change(User, :count)
    end

    it "タイトルが30文字以上の場合、失敗すること" do
      expect {
        fill_in "itinerary[title]", with: "a" * 31
        click_on "保存する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"

      }.not_to change(User, :count)
    end

    it "タイトルが同じユーザーで重複している場合、失敗すること" do
      create(:itinerary, owner: user)
      expect {
        fill_in "itinerary[title]", with: itinerary.title
        click_on "保存する"

        expect(page).to have_content "このタイトルはすでに使用されています"

      }.not_to change(User, :count)
    end

    it "出発日より前の日付は帰宅日として選択できないこと" do
      find("#departure-date-pickr").click
      find('div.dayContainer > span:nth-child(2)').click
      find("#return-date-pickr").click
      find('div.dayContainer > span:nth-child(1)').click

      click_on "保存する"

      expect(page).to have_content "帰宅日を入力してください"
    end
  end
  #   it "メールアドレスが重複している場合、失敗すること" do
  #     user.save
  #     expect {
  #       fill_in "ニックネーム", with: "other_user"
  #       fill_in "メールアドレス", with: user.email
  #       fill_in "パスワード", match: :first, with: "password"
  #       fill_in "パスワード（確認用）", with: "password"
  #       click_button "新規登録"

  #       aggregate_failures do
  #         expect(page).to have_content "アカウント登録"
  #         expect(page).to have_content "このメールアドレスはすでに登録されています"
  #         within ".navbar" do
  #           expect(page).not_to have_content user.name
  #         end
  #       end
  #     }.not_to change(User, :count)
  #   end
  # end

  # describe "パスワード変更" do
  #   let(:user) { create(:user) }

  #   before do
  #     sign_in user
  #     visit users_edit_password_path
  #   end

  #   context "有効な値の場合" do
  #     it "成功すること" do
  #       fill_in "現在のパスワード", with: user.password
  #       fill_in "新しいパスワード", match: :first, with: "newpassword"
  #       fill_in "新しいパスワード（確認用）", with: "newpassword"
  #       click_button "変更する"

  #       expect(current_path).to eq root_path

  #       sign_out user
  #       visit new_user_session_path
  #       fill_in "メールアドレス", with: user.email
  #       fill_in "パスワード", with: "newpassword"
  #       click_button "ログイン"

  #       expect(current_path).to eq root_path
  #       expect(page).not_to have_selector '.alert-notice', text: "ログインしました。"
  #     end
  #   end

  #   context "無効な値の場合" do
  #     it "現在のパスワードが間違っている場合、失敗すること" do
  #       fill_in "現在のパスワード", with: "wrongpassword"
  #       fill_in "新しいパスワード", match: :first, with: "newpassword"
  #       fill_in "新しいパスワード（確認用）", with: "newpassword"
  #       click_button "変更する"

  #       aggregate_failures do
  #         expect(page).to have_content "パスワードの変更"
  #         expect(page).to have_content "現在のパスワードが間違っています"
  #       end
  #     end

  #     it "新しいパスワードが5文字以下の場合、失敗すること" do
  #       fill_in "現在のパスワード", with: user.password
  #       fill_in "新しいパスワード", match: :first, with: "foo"
  #       fill_in "新しいパスワード（確認用）", with: "bar"
  #       click_button "変更する"

  #       aggregate_failures do
  #         expect(page).to have_content "パスワードの変更"
  #         expect(page).to have_content "パスワードは6文字以上で入力してください"
  #         expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
  #       end
  #     end

  #     it "新しいパスワードに半角英数字以外が含まれる場合、失敗すること" do
  #       fill_in "現在のパスワード", with: user.password
  #       fill_in "新しいパスワード", match: :first, with: "invalid_password"
  #       fill_in "新しいパスワード（確認用）", with: "invalid_password"
  #       click_button "変更する"

  #       aggregate_failures do
  #         expect(page).to have_content "パスワードの変更"
  #         expect(page).to have_content "パスワードは半角英数字で入力してください"
  #       end
  #     end
  #   end
  # end

  # describe "メールアドレス変更" do
  #   let(:user) { create(:user) }

  #   before do
  #     sign_in user
  #     visit users_edit_email_path
  #   end

  #   context "有効な値の場合" do
  #     it "成功すること" do
  #       fill_in "メールアドレス", with: "new_email_address@example.com"
  #       click_button "変更する"

  #       expect(current_path).to eq root_path
  #       expect(page).to have_content "メールアドレスを変更しました。"

  #       visit users_edit_email_path
  #       expect(page).to have_xpath "//input[@value='new_email_address@example.com']"
  #     end
  #   end

  #   context "無効な値の場合" do
  #     it "空欄の場合、失敗すること" do
  #       fill_in "メールアドレス", with: ""
  #       click_button "変更する"

  #       aggregate_failures do
  #         expect(page).to have_content "メールアドレスの変更"
  #         expect(page).to have_content "メールアドレスを入力してください"
  #       end
  #     end

  #     it "形式が正しくない場合、失敗すること" do
  #       fill_in "メールアドレス", with: "invalid_email_address"
  #       click_button "変更する"

  #       aggregate_failures do
  #         expect(page).to have_content "メールアドレスの変更"
  #         expect(page).to have_content "メールアドレスを正しく入力してください"
  #       end
  #     end
  #   end
  # end

  # describe "プロフィールの編集", focus: true do
  #   let(:user) { create(:user) }
  #   let(:other_user) { create(:user, :other) }

  #   before do
  #     sign_in user
  #     visit users_edit_profile_path
  #   end

  #   context "有効な値の場合", js: true do
  #     it "成功すること" do
  #       expect(page).to have_content "プロフィールの編集"
  #       expect(page).to have_xpath "//input[@value='Conan']"
  #       expect(page).to have_selector "img[src*='default_avatar']"

  #       find(".bi-question-circle-fill").hover
  #       expect(page).to have_content "旅のプランにメンバーを追加するときに使用するIDです。設定すると友だちがあなたをID検索できるようになります。"

  #       image_path = Rails.root.join('spec/fixtures/test_image.jpg')
  #       attach_file 'user[avatar]', image_path, make_visible: true

  #       expect(page).not_to have_selector "img[src*='default_avatar']"

  #       fill_in "ニックネーム", with: "Shinich"
  #       fill_in "BesTrip ID", with: "user_id"
  #       fill_in "user[introduction]", with: "I love traveling to different countries."
  #       click_on "保存する"

  #       expect(current_path).to eq root_path
  #       expect(page).to have_content "プロフィールを変更しました。"

  #       visit users_edit_profile_path
  #       expect(page).to have_selector "img[src*='test_image.jpg']"
  #       # visit users_edit_email_path プロフィールページにする？
  #       # expect(page).to have_xpath "//input[@value='new_email_address@example.com']"
  #     end
  #   end

  #   context "無効な値の場合" do
  #     it "ニックネームが空欄の場合、失敗すること" do
  #       fill_in "ニックネーム", with: ""
  #       click_on "保存する"

  #       aggregate_failures do
  #         expect(page).to have_content "プロフィールの編集"
  #         expect(page).to have_content "ニックネームを入力してください"
  #       end
  #     end

  #     it "自己紹介が文字数制限を超えている場合、「保存する」ボタンが押せないこと", js: true do
  #       fill_in "user[introduction]", with: "a" * 501

  #       expect(page).to have_content "500文字以内で入力してください"
  #       expect(page).to have_content "501"
  #       expect(find("#btn-submit", visible: false)).to be_disabled

  #       fill_in "user[introduction]", with: "a" * 500

  #       expect(page).not_to have_content "500文字以内で入力してください"
  #       expect(find("#btn-submit", visible: false)).not_to be_disabled
  #     end
  #   end

  #   describe "BesTrip IDの使用可否チェックボタン" do
  #     it "入力したIDがユニークな場合、使用可能メッセージが表示されること" do
  #       fill_in "BesTrip ID", with: "user_id"
  #       click_on "IDが使用可能か確認"

  #       expect(page).to have_content "このIDはご使用いただけます"
  #     end

  #     it "入力したIDが重複している場合、エラーメッセージが表示されること" do
  #       other_user.bestrip_id = "user_id"
  #       other_user.save

  #       fill_in "BesTrip ID", with: "user_id"
  #       click_on "IDが使用可能か確認"

  #       expect(page).to have_content "このIDは他の人が使用しています"
  #     end

  #     it "チェックボタンクリック後（Turbo_frameレンダリング後）、Javascriptが有効であること", js: true do
  #       click_on "IDが使用可能か確認"
  #       sleep 0.5

  #       image_path = Rails.root.join('spec/fixtures/test_image.jpg')
  #       attach_file 'user[avatar]', image_path, make_visible: true

  #       expect(page).not_to have_selector "img[src*='default_avatar']"

  #       find(".bi-question-circle-fill").hover
  #       expect(page).to have_content "旅のプランにメンバーを追加するときに使用するIDです。設定すると友だちがあなたをID検索できるようになります。"

  #       fill_in "user[introduction]", with: "a" * 501

  #       expect(page).to have_content "500文字以内で入力してください"
  #       expect(page).to have_content "501"
  #       expect(find("#btn-submit", visible: false)).to be_disabled
  #     end
  #   end
  # end
end