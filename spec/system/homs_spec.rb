RSpec.describe "Homes", type: :system do
  let(:user) { create(:user) }

  describe "楽しみ方ガイドページ", focus: true do
    before do
      visit guide_path
    end

    it "「旅の計画を始める」をクリックすると、アカウント作成画面へ遷移すること" do
      click_on "旅の計画を始める"

      expect(current_path).to eq new_user_registration_path
    end

    it "「ゲストログイン」をクリックすると、ゲストユーザーとしてログインすること" do
      click_on "ゲストログイン"

      expect(current_path).to eq itineraries_path
      within "header" do
        expect(page).to have_content "ゲスト様"
      end
    end

    it "ユーザーがログイン済みの場合、アカウント登録/ログインのリンクは表示されないこと" do
      sign_in user
      visit guide_path

      expect(page).not_to have_selector "a", text: "旅の計画を始める"
      expect(page).not_to have_selector "a", text: "ゲストログイン"
    end
  end
end
