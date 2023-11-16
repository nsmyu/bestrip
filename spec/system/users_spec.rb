RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let!(:post) { create(:post, :with_photo, itinerary: itinerary) }

  describe "プロフィール表示" do
    before do
      sign_in user
      visit user_path(id: user.id)
    end

    it "ユーザーのプロフィール情報を表示すること" do
      expect(page).to have_selector "img[src*='default_avatar']"
      expect(page).to have_content user.name
      expect(page).to have_content user.bestrip_id
      expect(page).to have_content user.introduction
    end

    it "ユーザーの投稿を表示すること" do
      expect(page).to have_content post.title
      expect(page).to have_content I18n.l post.created_at, format: :date_posted
    end

    context "ログインユーザー自身のプロフィールページの場合" do
      it "ドロップダウンメニューの「プロフィール編集」をクリックすると、プロフィール編集画面へ遷移すること" do
        find("i", text: "more_horiz", visible: false).click
        click_on "プロフィール編集"

        expect(page).to have_field 'user[name]', with: user.name
        expect(current_path).to eq users_edit_profile_path
      end

      it "「旅のプラン⚪︎件」をクリックすると、旅のプラン一覧画面へ遷移すること" do
        click_on "旅のプラン#{user.posts.count}件"

        expect(current_path).to eq itineraries_path
      end
    end

    context "ログインユーザー以外のプロフィールページの場合" do
      before do
        visit user_path(id: other_user.id)
      end

      it "ドロップダウンメニューが表示されないこと" do
        expect(page).not_to have_selector "i", text: "more_horiz"
      end

      it "「旅のプラン⚪︎件」がリンクではなく通常の文字列であること" do
        expect(page).to have_selector "p", text: "旅のプラン#{other_user.posts.count}件"
        expect(page).not_to have_selector "a", text: "旅のプラン#{other_user.posts.count}件"
      end
    end
  end
end
