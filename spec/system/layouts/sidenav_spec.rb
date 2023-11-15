RSpec.describe "サイドバー", type: :system do
  let(:user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }

  context "ユーザーがログインしていない場合" do
    it "サイドバーが表示されないこと" do
      expect(page).not_to have_selector ".sidenav"
    end
  end

  context "ユーザーがログイン済みの場合" do
    before do
      sign_in user
    end

    describe "「旅の計画」メニュー" do
      before do
        visit itineraries_path
      end

      it "「旅のプラン一覧」をクリックすると、旅のプラン一覧ページに遷移すること" do
        within ".sidenav" do
          click_on "旅のプラン一覧"
        end

        expect(current_path).to eq itineraries_path
      end

      it "「新しいプランを作成」をクリックすると、プラン作成モーダルを表示すること", js: true do
        within ".sidenav" do
          click_on "新しいプランを作成"
        end

        within(".modal") do
          expect(page).to have_content "旅のプラン新規作成"
        end
      end

      it "「お気に入りスポット」をクリックすると、お気に入りスポット一覧ページに遷移すること" do
        within ".sidenav" do
          click_on "お気に入りスポット"
        end

        expect(current_path).to eq users_places_path
      end

      it "「スポットを探す」をクリックすると、スポット検索ページに遷移すること" do
        within ".sidenav" do
          click_on "スポットを探す"
        end

        expect(current_path).to eq users_places_find_path
      end
    end

    describe "旅のプラン編集メニュー" do
      before do
        visit itinerary_path(id: itinerary.id)
      end

      it "旅のプランのタイトルをクリックすると、旅のプラン詳細ページに遷移すること" do
        within ".sidenav" do
          click_on itinerary.title
        end

        expect(current_path).to eq itinerary_path(id: itinerary.id)
      end

      it "「スケジュール」をクリックすると、スケジュール一覧ページに遷移すること" do
        within ".sidenav" do
          click_on "スケジュール"
        end

        expect(current_path).to eq itinerary_schedules_path(itinerary_id: itinerary.id)
      end

      it "「行きたい場所リスト」をクリックすると、行きたい場所リストページに遷移すること" do
        within ".sidenav" do
          click_on "行きたい場所リスト"
        end

        expect(current_path).to eq itinerary_places_path(itinerary_id: itinerary.id)
      end

      it "「スポットを探す」をクリックすると、スポット検索ページに遷移すること" do
        within ".sidenav" do
          click_on "スポットを探す"
        end

        expect(current_path).to eq itinerary_places_find_path(itinerary_id: itinerary.id)
      end
    end

    describe "個人設定メニュー" do
      before do
        visit users_edit_profile_path
      end

      it "「プロフィール編集」をクリックすると、プロフィール編集ページに遷移すること" do
        within ".sidenav" do
          click_on "プロフィール編集"
        end

        expect(current_path).to eq users_edit_profile_path
      end

      it "「メールアドレス変更」をクリックすると、メールアドレス変更ページに遷移すること" do
        within ".sidenav" do
          click_on "メールアドレス変更"
        end

        expect(current_path).to eq users_edit_email_path
      end

      it "「パスワード変更」をクリックすると、パスワード変更ページに遷移すること" do
        within ".sidenav" do
          click_on "パスワード変更"
        end

        expect(current_path).to eq edit_user_registration_path
      end
    end
  end
end
