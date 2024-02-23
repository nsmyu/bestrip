require "rails_helper"

RSpec.describe "ItineraryUsers", type: :system do
  describe "ユーザーをBesTrip IDで検索し、旅のメンバーに追加", js: true do
    let(:new_member) { create(:user) }

    shared_examples "旅のメンバー共通機能" do |user_type|
      before do
        set_signed_in_user(user_type)
        visit itinerary_path(itinerary.id)
        find("div.invitation-icon", match: :first).click
      end

      context "検索したユーザーをメンバーに追加できる場合" do
        it "ユーザーの情報を表示し、メンバー追加に成功すること" do
          expect {
            fill_in "bestrip_id", with: new_member.bestrip_id
            within '.modal' do
              click_on 'button'

              expect(page).to have_selector "img[src*='default_avatar']"
              expect(page).to have_content new_member.name

              click_on "メンバーに追加"
            end

            expect(page).to have_content "#{new_member.name}さんを旅のメンバーに追加しました。"
            expect(current_path).to eq itinerary_path(itinerary.id)
          }.to change { itinerary.confirmed_members.count }.by(1)
        end
      end

      context "検索したユーザーをメンバーに招待できない場合" do
        it "ユーザーが存在しない場合、その旨メッセージを表示すること" do
          fill_in "bestrip_id", with: "no_user_id"
          within '.modal' do
            click_on 'button'
          end

          expect(page).to have_content "ユーザーが見つかりませんでした"
          expect(page).not_to have_xpath "//input[@value='メンバーに追加']"
        end

        it "ユーザーが既にメンバーに含まれている場合、その旨メッセージを表示すること" do
          itinerary.members << new_member
          fill_in "bestrip_id", with: new_member.bestrip_id
          within '.modal' do
            click_on 'button'
          end

          expect(page).to have_content "すでにメンバーに含まれています"
          expect(page).not_to have_xpath "//input[@value='メンバーに追加']"
        end
      end
    end

    context "ログインユーザーがプラン作成者の場合" do
      let(:user) { create(:user) }
      let(:itinerary) { create(:itinerary, owner: user) }
      it_behaves_like "旅のメンバー共通機能", :owner
    end

    context "ログインユーザーがプラン作成者以外のメンバーの場合" do
      let(:user) { create(:user) }
      let(:itinerary) { create(:itinerary) }
      it_behaves_like "旅のメンバー共通機能", :member
    end
  end

  describe "旅のプラン一覧ページで招待通知に応答" do
    let(:invitee) { create(:user) }
    let(:itinerary_1) { create(:itinerary) }
    let(:itinerary_2) { create(:itinerary) }

    before do
      sign_in invitee
      create(:itinerary_user, user: invitee, itinerary: itinerary_1, confirmed: false)
      create(:itinerary_user, user: invitee, itinerary: itinerary_2, confirmed: false)
      visit itineraries_path
    end

    it "旅のプランへの招待通知を招待された日時の昇順で表示されること" do
      expect(page.text)
        .to match(/「#{itinerary_1.title}」に招待されています[\s\S]*「#{itinerary_2.title}」に招待されています/)
    end

    it "プランへの参加に成功すること" do
      expect do
        click_on "「#{itinerary_1.title}」に招待されています"
        click_on "この旅のプランに参加する"

        expect(page).not_to have_content "「#{itinerary_1.title}」に招待されています"
        expect(page).to have_content "旅のプランに参加しました。"
        expect(page).to have_content I18n.l itinerary_1.departure_date
        expect(current_path).to eq itineraries_path
      end.to change { itinerary_1.confirmed_members.count }.by(1)
    end

    it "招待の削除に成功すること" do
      expect do
        click_on "「#{itinerary_1.title}」に招待されています"
        within ".dropdown-center" do
          find("span", text: "参加しない（招待を削除）").click
          click_on "削除する"
        end

        expect(page).not_to have_content "「#{itinerary_1.title}」に招待されています"
        expect(page).not_to have_content I18n.l itinerary_1.departure_date
        expect(page).to have_content "「#{itinerary_1.title}」への招待を削除しました。"
        expect(current_path).to eq itineraries_path
      end.to not_change { itinerary_1.confirmed_members.count }
    end
  end

  describe "旅のプランからメンバー削除", js: true do
    let(:user) { create(:user) }
    let(:member) { create(:user) }
    let(:itinerary) { create(:itinerary, owner: user) }

    before do
      itinerary.members << member
    end

    it "成功すること" do
      sign_in user
      expect {
        visit itinerary_path(itinerary.id)
        find("i", text: "person_remove").click
        click_on "削除する"

        expect(page).to have_content "#{member.name}さんを旅のメンバーから削除しました。"
        expect(current_path).to eq itinerary_path(itinerary.id)
      }.to change { itinerary.confirmed_members.count }.by(-1)
    end

    it "プランの作成者以外はメンバー削除ができない（削除ボタンが表示されない）こと" do
      sign_in member

      visit itinerary_path(itinerary.id)
      expect(page).not_to have_selector "i", text: "person_remove"
    end
  end
end
