require "rails_helper"

RSpec.describe "ItineraryUsers", type: :system do
  let(:other_user) { create(:user, bestrip_id: "other_user_id") }

  describe "ユーザーを検索して旅のプランのメンバーに追加", js: true do
    shared_examples "旅のメンバー共通機能" do |user_type|
      before do
        set_signed_in_user(user_type)
        visit itinerary_path(itinerary.id)
        click_on "メンバーを追加"
      end

      it "検索したユーザーの情報を表示し、メンバー追加に成功すること" do
        expect {
          fill_in "bestrip_id", with: other_user.bestrip_id
          within '.modal' do
            click_on 'button'

            expect(page).to have_selector "img[src*='default_avatar']"
            expect(page).to have_content other_user.name
            expect(page).to have_xpath "//input[@value='メンバーに追加']"

            click_on "メンバーに追加"
          end

          expect(page).to have_content "メンバーを追加しました。"
          expect(page).to have_content other_user.name
          expect(current_path).to eq itinerary_path(itinerary.id)
        }.to change(itinerary.members, :count).by(1)
      end

      it "検索したユーザーが存在しない場合、その旨メッセージを表示し、追加ボタンは表示しないこと" do
        fill_in "bestrip_id", with: "no_user_id"
        within '.modal' do
          click_on 'button'
        end

        expect(page).to have_content "ユーザーが見つかりませんでした"
        expect(page).not_to have_xpath "//input[@value='メンバーに追加']"
      end

      it "検索したユーザーが既にメンバーに含まれている場合、その旨メッセージを表示し、追加ボタンは表示しないこと" do
        itinerary.members << other_user
        fill_in "bestrip_id", with: other_user.bestrip_id
        within '.modal' do
          click_on 'button'
        end

        expect(page).to have_content "すでにメンバーに追加されています"
        expect(page).not_to have_xpath "//input[@value='メンバーに追加']"
      end
    end

    context "ログインユーザーがプラン作成者の場合" do
      let(:user) { create(:user) }
      let(:itinerary) { create(:itinerary, owner: user) }
      it_behaves_like "旅のメンバー共通機能", :owner
    end

    context "ログインユーザーがプランの作成者以外のメンバーの場合" do
      let(:user) { create(:user) }
      let(:itinerary) { create(:itinerary) }
      it_behaves_like "旅のメンバー共通機能", :member
    end
  end

  describe "メンバー削除", js: true do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, bestrip_id: "other_user_id") }
    let(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << other_user
    end

    it "成功すること" do
      sign_in user
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "person_remove").click
        click_on "削除する"

        expect(page).to have_content "メンバーから削除しました。"
        expect(page).not_to have_content other_user.name
        expect(current_path).to eq itinerary_path(itinerary.id)
      }.to change(itinerary.members, :count).by(-1)
    end

    it "プランの作成者以外はメンバー削除ができない（削除ボタンが表示されない）こと" do
      sign_in other_user

      visit itinerary_path(itinerary.id)
      expect(page).not_to have_selector "i", text: "person_remove"
    end
  end
end
