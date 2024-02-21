require 'rails_helper'

RSpec.describe "Users::Invitations", type: :system do
  let(:user) { create(:user) }
  let(:invitee) { build(:user) }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:invitation_token) { Devise.token_generator.generate(User, :invitation_token) }
  # invitation_token[0]にトークン, invitation_token[1]にそのダイジェスト値が格納される

  describe "旅のプランへの招待メール送信" do
    before do
      sign_in user
      visit itinerary_path(itinerary.id)
    end

    context "正常な値の場合" do
      it "アカウント未登録ユーザーへのメール送信に成功し、再送信も成功すること" do
        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to change(User, :count).by(1).and change(PendingInvitation, :count).by(1)

        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change(User, :count).and not_change(PendingInvitation, :count)
      end

      it "既存ユーザーへの招待メール送信に成功し、再送信も成功すること" do
        invitee.save
        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change(User, :count).and change(PendingInvitation, :count).by(1)

        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change(User, :count).and not_change(PendingInvitation, :count)
      end
    end

    context "無効な値の場合", js: true do
      it "メールアドレスが空欄の場合、失敗すること" do
        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: ""
          click_on "招待メールを送る"

          expect(page).to have_content "メールアドレスを入力してください"
        end.to not_change(User, :count).and not_change(PendingInvitation, :count)
      end

      it "招待しようとしたユーザーが既にメンバーに含まれている場合、失敗すること" do
        invitee.save
        itinerary.members << invitee
        expect do
          click_on "メールでメンバーを招待"
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "#{invitee.name}さんはすでにメンバーに含まれています"
        end.to not_change(User, :count).and not_change(PendingInvitation, :count)
      end
    end
  end

  describe "旅のプランへの招待を承認" do
    before do
      invitee.save
      invitee.update(invitation_token: invitation_token[1])
      create(:pending_invitation, invitee: invitee, invited_to_itinerary: itinerary)
    end

    context "有効な値の場合" do
      it "アカウント未登録の場合、パスワード設定後にログインし、招待の承認に成功すること" do
        expect do
          visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                            itinerary_id: itinerary.id)
          fill_in "user[name]", with: invitee.name
          fill_in "user[password]", with: invitee.password
          fill_in "user[password_confirmation]", with: invitee.password_confirmation
          click_on "アカウント登録"

          expect(current_path).to eq itineraries_path

          click_on "この旅のプランに参加する"

          expect(page).to have_content "旅のプランに参加しました。"
          expect(page).to have_content itinerary.title
        end.to change(itinerary.members, :count).by(1).and change(PendingInvitation, :count).by(-1)
      end

      it "既存ユーザーの場合、ログイン後に招待の承認に成功すること" do
        expect do
          visit new_user_session_path(id: invitee.id, itinerary_id: itinerary.id)
          fill_in "user[password]", with: invitee.password
          click_button "ログイン"

          expect(current_path).to eq itineraries_path

          click_on "この旅のプランに参加する"

          expect(page).to have_content "旅のプランに参加しました。"
          expect(page).to have_content itinerary.title
        end.to change(itinerary.members, :count).by(1).and change(PendingInvitation, :count).by(-1)
      end
    end

    context "無効な値の場合" do
      it "ニックネームが空欄の場合、失敗すること" do
        expect do
          visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                            itinerary_id: itinerary.id)
          fill_in "user[name]", with: ""
          fill_in "user[password]", with: invitee.password
          fill_in "user[password_confirmation]", with: invitee.password_confirmation
          click_on "アカウント登録"

          expect(page).to have_content "ニックネームを入力してください"
        end.not_to change(PendingInvitation, :count)
      end

      it "パスワードが空欄の場合、失敗すること" do
        expect do
          visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                            itinerary_id: itinerary.id)
          fill_in "user[name]", with: invitee.name
          fill_in "user[password]", with: ""
          fill_in "user[password_confirmation]", with: ""
          click_on "アカウント登録"

          expect(page).to have_content "パスワードを入力してください"
        end.not_to change(PendingInvitation, :count)
      end

      it "確認用パスワードが一致しない場合、失敗すること" do
        expect do
          visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                            itinerary_id: itinerary.id)
          fill_in "user[name]", with: invitee.name
          fill_in "user[password]", with: invitee.password
          fill_in "user[password_confirmation]", with: "wrongpassword"
          click_on "アカウント登録"

          expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
        end.not_to change(PendingInvitation, :count)
      end
    end
  end

  describe "旅のプラン一覧ページ" do
    it "旅のプランへの招待通知を招待された日時の昇順で表示されること" do
      invitee.save
      itinerary_1 = create(:itinerary)
      itinerary_2 = create(:itinerary)
      create(:pending_invitation, invitee: invitee, invited_to_itinerary: itinerary_1)
      create(:pending_invitation, invitee: invitee, invited_to_itinerary: itinerary_2)
      sign_in invitee
      visit itineraries_path

      expect(page.text)
        .to match(/「#{itinerary_1.title}」に招待されています[\s\S]*「#{itinerary_2.title}」に招待されています/)
    end

    describe "招待通知への応答" do
      before do
        sign_in invitee
        invitee.save
        create(:pending_invitation, invitee: invitee, invited_to_itinerary: itinerary)
        visit itineraries_path
        click_on "「#{itinerary.title}」に招待されています"
      end

      it "プランへの参加に成功すること" do
        expect do
          click_on "この旅のプランに参加する"

          expect(page).to have_content "旅のプランに参加しました。"
          expect(page).not_to have_content "「#{itinerary.title}」に招待されています"
          expect(current_path).to eq itineraries_path
        end.to change(itinerary.members, :count).by(1).and change(PendingInvitation, :count).by(-1)
      end

      it "招待の削除に成功すること" do
        expect do
          within ".dropdown-center" do
            find("span", text: "参加しない（招待を削除）").click
            click_on "削除する"
          end

          expect(page).to have_content "「#{itinerary.title}」への招待を削除しました。"
          expect(page).not_to have_content "「#{itinerary.title}」に招待されています"
          expect(current_path).to eq itineraries_path
        end.to not_change(itinerary.members, :count).and change(PendingInvitation, :count).by(-1)
      end
    end
  end
end
