RSpec.describe "ヘッダー", type: :system do
  let(:user) { create(:user) }

  it "BesTripロゴをクリックすると、トップページに遷移すること" do
    visit root_path
    find(".navbar-brand").click

    assert_current_path root_path
  end

  context "ユーザーがログインしていない場合" do
    before do
      visit root_path
    end

    it "「アカウント登録」をクリックすると、アカウント登録ページに遷移すること" do
      within "header" do
        find(".nav-link", text: "アカウント登録").click
      end

      assert_current_path new_user_registration_path
    end

    it "「ログイン」をクリックすると、ログインページに遷移すること" do
      within "header" do
        find(".nav-link", text: "ログイン").click
      end

      assert_current_path new_user_session_path
    end
  end

  context "ユーザーがログイン済みの場合" do
    before do
      sign_in user
      visit root_path
    end

    it "「旅の計画」をクリックすると、旅のプラン一覧ページに遷移すること" do
      within "header" do
        click_on "旅の計画"
      end

      assert_current_path itineraries_path
    end

    it "BesTripアイコンをクリックすると、投稿一覧ページに遷移すること" do
      within "header" do
        find(:xpath, "//img[contains(@src, 'brand_icon_charcoal')]").click
      end

      assert_current_path root_path
    end

    it "ハートのアイコンをクリックすると、お気に入りスポット一覧ページに遷移すること", js: true do
      within "header" do
        find("i", text: "favorite_border").click
      end

      assert_current_path users_places_path
    end

    describe "旅のプランへの招待通知" do
      it "招待がある場合、旅のプラン一覧ページへのリンクを表示すること", js: true do
        itinerary = create(:itinerary)
        create(:pending_invitation, invitee: user, invited_to_itinerary: itinerary)
        visit root_path
        within "header" do
          find("i", text: "notifications").click
        end

        click_on "1件の旅のプランに招待されています"
        assert_current_path itineraries_path
      end

      it "招待が無い場合、通知アイコンをクリックすると「お知らせはありません」と表示すること", js: true do
        within "header" do
          find("i", text: "notifications").click
        end

        expect(page).to have_content "お知らせはありません"
      end
    end

    describe "アカウント設定のドロップダウンメニュー" do
      it "ユーザーのニックネームとアバター画像を表示すること" do
        within "header" do
          expect(page).to have_selector "img[src*='default_avatar']"
          expect(page).to have_content user.name
        end
      end

      it "「プロフィール」をクリックすると、自分のプロフィールページへ遷移すること", js: true do
        within "header" do
          find("p", text: user.name).click
          click_on "プロフィール"
        end

        assert_current_path user_path(id: user.id)
      end

      it "「メールアドレス変更」をクリックすると、メールアドレス変更ページへ遷移すること", js: true do
        within "header" do
          find("p", text: user.name).click
          click_on "メールアドレス変更"
        end

        expect users_edit_email_path
      end

      it "「パスワード変更」をクリックすると、パスワード変更ページへ遷移すること", js: true do
        within "header" do
          find("p", text: user.name).click
          click_on "パスワード変更"
        end

        assert_current_path edit_user_registration_path
      end
      # ドロップダウンメニュー「ログアウト」のテストはusers_sessions_spec.rbで行う
    end
  end
end
