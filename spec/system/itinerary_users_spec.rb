require "rails_helper"

RSpec.describe "ItineraryUsers", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, bestrip_id: "other_user_id") }
  let!(:itinerary) { create(:itinerary, owner: user) }

  before do
    sign_in user
  end

  describe "ユーザー検索、メンバー追加", js: true do
    before do
      visit itinerary_path(itinerary.id)
      click_on "メンバーを追加"
    end

    it "成功すること" do
      expect {
        fill_in "bestrip_id", with: other_user.bestrip_id
        find("i", text: "search").click

        expect(page).to have_content other_user.name

        click_on "メンバーに追加"

        expect(current_path).to eq itinerary_path(itinerary.id)
        expect(page).to have_content other_user.name
      }.to change(itinerary.members, :count).by(1)
    end

    it "検索したユーザーが存在しない場合、メッセージが表示されること" do
      fill_in "bestrip_id", with: "no_user_id"
      find("i", text: "search").click
      expect(page).to have_content "ユーザーが見つかりませんでした"
    end

    it "検索したユーザーが既にメンバーに含まれている場合、メッセージが表示されること" do
      itinerary.members << other_user
      fill_in "bestrip_id", with: other_user.bestrip_id
      find("i", text: "search").click
      expect(page).to have_content "すでにメンバーに追加されています"
    end
  end

  describe "メンバー削除", js: true do
    before do
      itinerary.members << other_user
    end

    it "成功すること" do
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "person_remove").click
        click_on "削除する"
        expect(current_path).to eq itinerary_path(itinerary.id)
        expect(page).not_to have_content other_user.name
      }.to change(itinerary.members, :count).by(-1)
    end

    it "作成者以外にはメンバー削除ができない（削除ボタンが表示されない）こと" do
      sign_out user
      sign_in other_user
      visit itinerary_path(itinerary.id)
      expect(page).not_to have_selector "i", text: "person_remove"
    end
  end
end
