RSpec.describe "Homes", type: :system do
  let(:user) { create(:user) }

  describe "楽しみ方ガイドページ" do
    context "ユーザーがログインしていない場合" do
      before do
        visit guide_path
      end

      it "アカウント登録ページとログインページへのリンクが表示されること" do
        expect(page).to have_link "旅の計画を始める", href: "/users/sign_up"
        expect(page).to have_link "ゲストログイン", href: "/users/guest_sign_in"
      end

      it "「旅の計画を始める」をクリックすると、アカウント登録ページへ遷移すること" do
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
    end

    context "ユーザーがログイン済みの場合" do
      it "アカウント登録ページとログインページへのリンクが表示されないこと" do
        sign_in user
        visit guide_path

        expect(page).not_to have_link "旅の計画を始める", href: "/users/sign_up"
        expect(page).not_to have_link "ゲストログイン", href: "/users/guest_sign_in"
      end
    end
  end
end
