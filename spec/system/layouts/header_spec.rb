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

    it "「?」アイコンをクリックすると、楽しみ方ガイドページに遷移すること", js: true do
      within "header" do
        find("i", text: "help_outline").click
      end

      assert_current_path guide_path
    end

    it "ハートのアイコンをクリックすると、お気に入りスポット一覧ページに遷移すること", js: true do
      within "header" do
        find("i", text: "favorite_border").click
      end

      assert_current_path users_places_path
    end

    it "BesTripアイコンをクリックすると、投稿一覧ページに遷移すること" do
      within "header" do
        find(:xpath, "//img[contains(@src, 'brand_icon_charcoal')]").click
      end

      assert_current_path root_path
    end

    it "ドロップダウンメニューの「プロフィール」をクリックすると、自分のプロフィールページへ遷移すること", js: true do
      within "header" do
        find("p", text: user.name).hover
        click_on "プロフィール"
      end

      assert_current_path user_path(id: user.id)
    end

    it "ドロップダウンメニューの「メールアドレス変更」をクリックすると、メールアドレス変更ページへ遷移すること", js: true do
      within "header" do
        find("p", text: user.name).hover
        click_on "メールアドレス変更"
      end

      expect users_edit_email_path
    end

    it "ドロップダウンメニューの「パスワード変更」をクリックすると、パスワード変更ページへ遷移すること", js: true do
      within "header" do
        find("p", text: user.name).hover
        click_on "パスワード変更"
      end

      assert_current_path edit_user_registration_path
    end

    # ドロップダウンメニュー「ログアウト」のテストはusers_sessions_spec.rbで行う
  end
end
