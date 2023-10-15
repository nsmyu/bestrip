require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let!(:user) { create(:user) }
  let!(:itinerary) { create(:itinerary, owner: user) }
  let(:post) { build(:post) }
  let(:photo) { build(:photo) }

  before do
    sign_in user
  end

  # describe "一覧表示" do
  #   context "スケジュールが登録されている場合" do
  #     let!(:post1) { create(:post, itinerary: itinerary) }

  #     it "スケジュールを日付の昇順で表示すること" do
  #       post2 = create(:post, post_date: "2024-02-01", itinerary: itinerary)
  #       post3 = create(:post, post_date: "2024-02-03", itinerary: itinerary)

  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       expect(page.text)
  #         .to match(/#{post2.title}[\s\S]*#{post1.title}[\s\S]*#{post3.title}/)
  #     end

  #     it "同日のスケジュールを開始時間の昇順で表示すること" do
  #       post2 = create(:post, start_at: "12:00:00", itinerary: itinerary)
  #       post3 = create(:post, start_at: "14:00:00", itinerary: itinerary)

  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       within(:xpath, "//div[h5[contains(text(), '#{I18n.l post.post_date}')]]") do
  #         expect(page.text)
  #           .to match(/#{post2.title}[\s\S]*#{post1.title}[\s\S]*#{post3.title}/)
  #       end
  #     end

  #     it "スケジュールのタイトル、アイコン、日付、時間を表示すること" do
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)

  #       within(:xpath, "//div[h5[contains(text(), '#{I18n.l post1.post_date}')]]") do
  #         expect(page).to have_content post1.icon
  #         expect(page).to have_content post1.title
  #         expect(page).to have_content I18n.l post1.start_at
  #         expect(page).to have_content I18n.l post1.end_at
  #       end
  #     end

  #     it "他の旅のプランのスケジュールが表示されていないこと" do
  #       other_itinerary = create(:itinerary, owner: user)
  #       other_itinerary_post = create(:post, itinerary: other_itinerary)
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)

  #       expect(page).not_to have_content other_itinerary_post.title
  #     end
  #   end

  #   describe "リンクのテスト" do
  #     let!(:post) { create(:post, itinerary: itinerary) }

  #     it "ドロップダウンメニューの「情報を見る」をクリックすると、スケジュール詳細モーダルを表示すること", js: true do
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       find(".post-dropdown-icon", match: :first).click
  #       click_on "情報を見る", match: :first

  #       within(".modal") do
  #         expect(page).to have_content "スケジュール詳細"
  #         expect(page).to have_content post.title
  #       end
  #     end

  #     it "ドロップダウンメニューの「編集」をクリックすると、スケジュール編集モーダルを表示すること", js: true do
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       find(".post-dropdown-icon", match: :first).click
  #       click_on "編集", match: :first

  #       within(".modal") do
  #         expect(page).to have_content "スケジュール編集"
  #         expect(page).to have_xpath "//input[@value='#{post.title}']"
  #       end
  #     end

  #     it "「スケジュール作成」をクリックすると、スケジュール作成モーダルを表示すること", js: true do
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       click_on "スケジュール作成"

  #       within(".modal") do
  #         expect(page).to have_content "スケジュール作成"
  #       end
  #     end
  #   end
  # end

  describe "新規作成", js: true do
    before do
      visit new_post_path
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          find(".select-box").click
          find("option", text: "#{itinerary.title}").click
          image_path = Rails.root.join('spec/fixtures/test_image.jpg')
          attach_file "post[photos_attributes][0][url]", image_path, make_visible: true
          fill_in "post[title]", with: post.title
          fill_in "post[caption]", with: post.caption
          click_on "投稿する"

          expect(page).to have_content "旅の思い出を投稿しました。"
          # within(:xpath, "//div[h5[contains(text(), '#{I18n.l post.post_date}')]]") do
          #   expect(page).to have_content post.title
          #   expect(page).to have_content post.icon
          #   expect(page).to have_content I18n.l post.start_at
          #   expect(page).to have_content I18n.l post.end_at
          #   expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"
          # end
          # expect(current_path).to eq itinerary_posts_path(itinerary_id: itinerary.id)

          # find(".post-dropdown-icon", match: :first).click
          # click_on "情報を見る", match: :first

          # expect(page).to have_content post.note
        }.to change(Post, :count).by(1)
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        expect {
          click_on "投稿する"

          expect(page).to have_content "旅のプランを選択してください"
          expect(page).to have_content "写真は1枚以上選択してください"
          expect(page).to have_content "タイトルを入力してください"
        }.not_to change(Post, :count)
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        expect {
          fill_in "post[title]", with: "a" * 31
          click_on "投稿する"

          expect(page).to have_content "タイトルは30文字以内で入力してください"
        }.not_to change(Post, :count)
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが押せないこと" do
        fill_in "post[caption]", with: "a" * 1000

        expect(page).to have_content "1000"
        expect(find("#submit_btn")).not_to be_disabled

        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  # describe "詳細表示", js: true do
  #   context "有効な値の場合" do
  #     let!(:post) { create(:post, itinerary: itinerary) }

  #     before do
  #       visit itinerary_post_path(itinerary_id: itinerary.id, id: post.id)
  #     end

  #     it "スケジュールのタイトル、アイコン、日付、時間、メモを表示すること" do
  #       expect(page).to have_content post.title
  #       expect(page).to have_content post.icon
  #       expect(page).to have_content I18n.l post.post_date
  #       expect(page).to have_content I18n.l post.start_at
  #       expect(page).to have_content I18n.l post.end_at
  #       expect(page).to have_content post.note
  #     end

  #     it "スケジュールのスポット情報を表示すること" do
  #       expect(page).to have_content "シドニー・オペラハウス"
  #       expect(page).to have_content "Bennelong Point, Sydney NSW 2000 オーストラリア"
  #       expect(page).to have_selector "img[src*='maps.googleapis.com/maps/api/place/photo']"
  #       expect(page).to have_selector "iframe[src$='place_id:#{post.place_id}']"
  #     end
  #   end
  # end

  describe "編集", js: true do
    let!(:post_with_photo) { create(:post, :with_photo, itinerary: itinerary) }

    before do
      visit edit_post_path(id: post_with_photo.id)
    end

    context "有効な値の場合" do
      it "成功すること" do
        other_itinerary = create(:itinerary, owner: user)
        visit edit_post_path(id: post_with_photo.id)
        find(".select-box").click
        find("option", text: "#{other_itinerary.title}").click
        fill_in "post[title]", with: "New title"
        fill_in "post[caption]", with: "New caption."
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
          # within(:xpath, "//div[h5[contains(text(), '#{I18n.l post.post_date}')]]") do
          #   expect(page).to have_content post.title
          #   expect(page).to have_content post.icon
          #   expect(page).to have_content I18n.l post.start_at
          #   expect(page).to have_content I18n.l post.end_at
          #   expect(page).not_to have_selector "img[id='image_preview'][src*='default_itinerary']"
          # end
          # expect(current_path).to eq itinerary_posts_path(itinerary_id: itinerary.id)

          # find(".post-dropdown-icon", match: :first).click
          # click_on "情報を見る", match: :first

          # expect(page).to have_content post.note
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        find(".select-box").click
        find("option", text: "旅のプランを選択").click
        find("i", text: "close").click
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "旅のプランを選択してください"
        expect(page).to have_content "写真は1枚以上選択してください"
        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが空欄の場合、失敗すること" do
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "タイトルを入力してください"
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        fill_in "post[title]", with: "a" * 31
        click_on "投稿する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが押せないこと" do
        fill_in "post[caption]", with: "a" * 1000

        expect(page).to have_content "1000"
        expect(find("#submit_btn")).not_to be_disabled

        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  # describe "削除", js: true do
  #   let!(:post) { create(:post, itinerary: itinerary) }

  #   it "成功すること" do
  #     expect {
  #       visit itinerary_posts_path(itinerary_id: itinerary.id)
  #       find(".post-dropdown-icon", match: :first).click
  #       click_on "削除", match: :first

  #       expect(page).to have_content "このスケジュールを削除しますか？この操作は取り消せません。"

  #       click_on "削除する"

  #       expect(page).to have_content "スケジュールを削除しました。"
  #       expect(current_path).to eq itinerary_posts_path(itinerary_id: itinerary.id)
  #     }.to change(Schedule, :count).by(-1)
  #   end
  # end
end
