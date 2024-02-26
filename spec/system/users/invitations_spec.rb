require 'rails_helper'

RSpec.describe "Users::Invitations", type: :system do
  let(:user) { create(:user) }
  let(:invitee) { build(:user, name: "newly_invited") }
  let(:itinerary) { create(:itinerary, owner: user) }
  let(:invitation_token) { Devise.token_generator.generate(User, :invitation_token) }
  # invitation_token[0]にトークン, invitation_token[1]にそのダイジェスト値が格納される

  describe "旅のプランへの招待メール送信" do
    before do
      sign_in user
      visit itinerary_path(itinerary.id)
    end

    context "正常な値の場合", js: true do
      it "アカウント未登録ユーザーへのメール送信及び再送信に成功し、DBが正しく更新されること" do
        expect do
          find("i", text: "email").click
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"
          sleep 2.5

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to change { User.count }.by(1).and change { itinerary.invitees.count }.by(1)
          .and change { ActionMailer::Base.deliveries.size }.by(1)

        expect do
          visit itinerary_path(itinerary.id)
          find("i", text: "email").click
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"
          sleep 2.5

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change{ User.count }.and not_change { itinerary.invitees.count }
          .and change { ActionMailer::Base.deliveries.size }.by(1)
      end

      it "既存ユーザーへの招待メール送信及び再送信に成功し、DBが正しく更新されること" do
        invitee.save
        expect do
          find("i", text: "email").click
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"
          sleep 2.5

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change { User.count }.and change { itinerary.invitees.count }.by(1)
          .and change { ActionMailer::Base.deliveries.size }.by(1)

        expect do
          visit itinerary_path(itinerary.id)
          find("i", text: "email").click
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"
          sleep 2.5

          expect(page).to have_content "招待メールを#{invitee.email}に送信しました。"
          expect(current_path).to eq itinerary_path(itinerary.id)
        end.to not_change { User.count }.and not_change { itinerary.invitees.count }
          .and change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context "無効な値の場合", js: true do
      it "メールアドレスが空欄の場合、失敗すること" do
        expect do
          find("i", text: "email").click
          fill_in "user[email]", with: ""
          click_on "招待メールを送る"

          expect(page).to have_content "メールアドレスを入力してください"
        end.to not_change { User.count }.and not_change { itinerary.invitees.count }
          .and not_change { ActionMailer::Base.deliveries.size }
      end

      it "招待しようとしたユーザーが既にメンバーに含まれている場合、失敗すること" do
        invitee.save
        itinerary.members << invitee
        expect do
          find("i", text: "email").click
          fill_in "user[email]", with: invitee.email
          click_on "招待メールを送る"

          expect(page).to have_content "#{invitee.name}さんはすでにメンバーに含まれています"
        end.to not_change { User.count }.and not_change { itinerary.invitees.count }
          .and not_change { ActionMailer::Base.deliveries.size }
      end
    end
  end

  describe "招待メールから旅のプランに参加" do
    context "アカウント未登録（パスワード未設定）の場合" do
      before do
        invitee.save
        invitee.update(invitation_token: invitation_token[1])
        create(:pending_invitation, user: invitee, itinerary: itinerary)
        visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                          itinerary_id: itinerary.id)
      end

      context "有効な値の場合" do
        it "パスワード設定後にログインし、招待の承認に成功すること" do
          expect do
            fill_in "user[name]", with: invitee.name
            fill_in "user[password]", with: invitee.password
            fill_in "user[password_confirmation]", with: invitee.password_confirmation
            click_on "アカウント登録"

            expect(current_path).to eq itineraries_path

            click_on "この旅のプランに参加する"

            expect(page).to have_content "旅のプランに参加しました。"
            expect(page).to have_content I18n.l itinerary.departure_date
          end
            .to change { itinerary.members.count }.by(1)
            .and change { itinerary.invitees.count }.by(-1)
        end

        it "パスワード設定画面で、招待されているプランの情報を表示すること" do
          expect(page).to have_content itinerary.title
          expect(page).to have_content I18n.l itinerary.departure_date
          expect(page).to have_content I18n.l itinerary.return_date
        end
      end

      context "無効な値の場合" do
        it "ニックネームが空欄の場合、失敗すること" do
          expect do
            fill_in "user[name]", with: ""
            fill_in "user[password]", with: invitee.password
            fill_in "user[password_confirmation]", with: invitee.password_confirmation
            click_on "アカウント登録"

            expect(page).to have_content "ニックネームを入力してください"
          end.to not_change { itinerary.members.count }.and not_change { itinerary.invitees.count }
        end

        it "パスワードが空欄の場合、失敗すること" do
          expect do
            fill_in "user[name]", with: invitee.name
            fill_in "user[password]", with: ""
            fill_in "user[password_confirmation]", with: ""
            click_on "アカウント登録"

            expect(page).to have_content "パスワードを入力してください"
          end.to not_change { itinerary.members.count }.and not_change { itinerary.invitees.count }
        end

        it "確認用パスワードが一致しない場合、失敗すること" do
          expect do
            fill_in "user[name]", with: invitee.name
            fill_in "user[password]", with: invitee.password
            fill_in "user[password_confirmation]", with: "wrongpassword"
            click_on "アカウント登録"

            expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
          end.to not_change { itinerary.members.count }.and not_change { itinerary.invitees.count }
        end
      end
    end

    context "既存ユーザーの場合" do
      it "ログインページにリダイレクトされ、ログイン後に招待の承認に成功すること" do
        invitee = create(:invitee, name: "existing_user")
        invitee.update(invitation_token: invitation_token[1])
        create(:pending_invitation, user: invitee, itinerary: itinerary)

        expect do
          visit accept_user_invitation_path(invitation_token: invitation_token[0],
                                            itinerary_id: itinerary.id)

          expect(current_path).to eq new_user_session_path

          fill_in "user[password]", with: invitee.password
          click_button "ログイン"

          expect(current_path).to eq itineraries_path

          click_on "この旅のプランに参加する"

          expect(page).to have_content "旅のプランに参加しました。"
          expect(page).to have_content I18n.l itinerary.departure_date
        end
          .to change { itinerary.members.count }.by(1)
          .and change { itinerary.invitees.count } .by(-1)
      end
    end
  end
end
