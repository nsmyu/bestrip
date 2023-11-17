require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary_1) { create(:itinerary, :with_schedule, owner: user) }
  let(:itinerary_2) { create(:itinerary, :with_schedule, owner: user) }
  let!(:post_1) { create(:post, :caption_great_with_hashtag, :with_photo, itinerary: itinerary_1) }
  let!(:post_2) { create(:post, :caption_awesome_no_hashtag, :with_photo, itinerary: itinerary_2) }

  describe "一覧表示" do
    before do
      visit posts_path
    end

    it "投稿を作成日の降順で表示すること" do
      now = Time.current
      post_2_days_ago =
        create(:post, :with_photo, created_at: now.ago(2.days), itinerary: itinerary_1)
      post_yesterday = create(:post, :with_photo, created_at: now.yesterday, itinerary: itinerary_1)
      post_today = create(:post, :with_photo, created_at: now, itinerary: itinerary_1)
      visit posts_path

      expect(page.text)
        .to match /#{post_today.title}[\s\S]*#{post_yesterday.title}[\s\S]*#{post_2_days_ago.title}/
    end

    it "投稿のタイトル、写真、投稿者名、投稿日を表示すること" do
      within("turbo-frame#post_#{post_1.id}") do
        expect(page).to have_content post_1.user.name
        expect(page).to have_selector "img[src$='cat.jpg']"
        expect(page).to have_content post_1.title
        expect(page).to have_content I18n.l post_1.created_at, format: :date_posted
      end
    end

    it "投稿をクリックすると、投稿詳細ページへ遷移すること" do
      click_on post_1.title

      expect(current_path).to eq post_path(post_1.id)
      expect(page).to have_content post_1.title
    end

    context "ユーザーがログインしていない場合" do
      it "「旅の思い出を投稿」をクリックすると、ログインページに遷移すること" do
        click_on "旅の思い出を投稿"

        expect(current_path).to eq new_user_session_path
      end
    end

    context "ユーザーがログイン済みの場合" do
      it "「旅の思い出を投稿」をクリックすると、投稿作成モーダルを表示すること", js: true do
        sign_in user
        visit posts_path
        click_on "旅の思い出を投稿"

        within(".modal") do
          expect(page).to have_content "旅の思い出を投稿"
        end
      end
    end
  end

  describe "投稿を検索" do
    before do
      visit posts_path
    end

    it "タイトルにキーワードが含まれる投稿を表示すること" do
      fill_in "keyword", with: post_1.title.slice(/Trip_\d+/)
      find("#keyword").sibling("button").click

      expect(page).to have_content post_1.title
      expect(page).not_to have_content post_2.title
    end

    it "キャプションにキーワードが含まれる投稿を表示すること" do
      fill_in "keyword", with: "great"
      find("#keyword").sibling("button").click

      expect(page).to have_content post_1.title
      expect(page).not_to have_content post_2.title
    end

    it "関連付けられたプランのスケジュールにキーワードが含まれる投稿を表示すること" do
      fill_in "keyword", with: itinerary_1.schedules[0].title
      find("#keyword").sibling("button").click

      expect(page).to have_content post_1.title
      expect(page).not_to have_content post_2.title
    end

    it "キーワードに該当する投稿が無い場合、その旨メッセージを取得すること" do
      fill_in "keyword", with: "find_nothing"
      find("#keyword").sibling("button").click

      expect(page).to have_content "「find_nothing」に一致する投稿は見つかりませんでした"
    end
  end

  describe "新規作成", js: true do
    let(:new_post) { build(:post, :caption_great_with_hashtag) }

    before do
      sign_in user
      visit posts_path
      click_on "旅の思い出を投稿"
    end

    context "有効な値の場合" do
      it "成功すること" do
        expect {
          find(".select-box").click
          find("option", text: "#{itinerary_1.title}").click
          image_path = Rails.root.join('spec/fixtures/cat.jpg')
          attach_file "post[photos_attributes][0][url]", image_path, make_visible: true
          fill_in "post[title]", with: new_post.title
          fill_in "post[caption]", with: new_post.caption
          click_on "投稿する"

          expect(page).to have_content "旅の思い出を投稿しました。"
          expect(page).to have_selector "img[src$='cat.jpg']"
          expect(page).to have_content new_post.title
          expect(page).to have_content new_post.caption
          expect(current_path).to eq post_path(id: Post.last.id)
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

      it "写真が20枚添付されると、「画像を選択」ボタンが無効化されること" do
        find(".select-box").click
        image_path = Rails.root.join('spec/fixtures/cat.jpg')
        20.times do |i|
          attach_file "post[photos_attributes][#{i}][url]", image_path, make_visible: true
        end

        expect(find("input.active-field", visible: false).find(:xpath, ".."))
          .to match_css(".disabled")
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが無効化されること" do
        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  describe "詳細表示" do
    before do
      visit post_path(id: post_1.id)
    end

    it "投稿の各情報を表示すること" do
      expect(page).to have_selector "img[src$='cat.jpg']"
      expect(page).to have_content post_1.title
      expect(page).to have_content post_1.user.name
      expect(page).to have_content post_1.caption
      expect(page).to have_content I18n.l post_1.created_at, format: :date_posted
    end

    it "ハッシュタグをクリックすると、一覧表示ページに遷移し、ハッシュタグを含む投稿を表示すること" do
      visit post_path(id: post_1.id)
      click_on "#bestrip"

      expect(page).to have_content post_1.title
      expect(page).not_to have_content post_2.title
      expect(current_path).to eq search_posts_path
    end

    context "ログインユーザーが投稿の作成者である場合" do
      it "ドロップダウンメニューを表示すること" do
        sign_in user
        visit post_path(id: post_1.id)

        expect(page).to have_selector "button[id='post_dropdown']"
      end

      it "ドロップダウンメニューの「編集」をクリックすると、投稿編集モーダルを表示すること", js: true do
        sign_in user
        visit post_path(id: post_1.id)
        find("i", text: "more_horiz", visible: false).click
        click_on "編集"

        within(".modal") do
          expect(page).to have_content "投稿の編集"
          expect(page).to have_field 'post[title]', with: post_1.title
        end
      end
      # ドロップダウンメニュー「削除」のリンクについては、後述の削除処理でテストを行う
    end

    context "ログインユーザーが投稿の作成者ではない場合" do
      it "ドロップダウンメニューを表示しないこと" do
        sign_in other_user
        visit post_path(id: post_1.id)

        expect(page).not_to have_selector "button[id='post_dropdown']"
      end
    end

    describe "投稿に関連付けられたプランのスケジュール表示" do
      it "スケジュールの各情報を表示すること" do
        expect(page).to have_content I18n.l itinerary_1.schedules[0].start_at
        expect(page).to have_content itinerary_1.schedules[0].icon
        expect(page).to have_content itinerary_1.schedules[0].title
      end

      it "スケジュールを日付順で表示すること" do
        schedule_1st_day = create(:schedule, date: itinerary_1.departure_date,
                                             itinerary: itinerary_1)
        schedule_2nd_day = create(:schedule, date: itinerary_1.departure_date.tomorrow,
                                             itinerary: itinerary_1)
        schedule_8th_day = create(:schedule, date: itinerary_1.return_date,
                                             itinerary: itinerary_1)

        visit post_path(id: post_1.id)

        expect(page.text).to match /#{"1日目"}[\s\S]*#{"2日目"}[\s\S]*#{"8日目"}/
        within(:xpath, "//div[h6[contains(text(), '1日目')]]") do
          expect(page).to have_content schedule_1st_day.title
        end
        within(:xpath, "//div[h6[contains(text(), '2日目')]]") do
          expect(page).to have_content schedule_2nd_day.title
        end
        within(:xpath, "//div[h6[contains(text(), '8日目')]]") do
          expect(page).to have_content schedule_8th_day.title
        end
      end

      it "スケジュール右側のアイコンをクリックすると、スポット情報のモーダルを表示すること", js: true do
        within(:xpath, "//div[div[p[contains(text(), '#{itinerary_1.schedules[0].title}')]]]") do
          find("i", text: "pin_drop").click
        end

        within(".modal") do
          expect(page).to have_content "スポット情報"
          expect(page).to have_content "シドニー・オペラハウス"
        end
      end

      it "投稿のプラン公開設定が非公開に設定されている場合は、スケジュールを表示しないこと" do
        post_1.update(itinerary_public: false)
        visit post_path(id: post_1.id)

        expect(page).not_to have_content itinerary_1.schedules[0].title
      end
    end
  end

  describe "編集", js: true do
    before do
      sign_in user
      visit edit_post_path(id: post_1.id)
    end

    context "有効な値の場合" do
      it "画像以外の各項目の変更に成功すること" do
        visit edit_post_path(id: post_1.id)
        find(".select-box").click
        find("option", text: "#{itinerary_2.title}").click
        fill_in "post[title]", with: "Edited title"
        fill_in "post[caption]", with: "Edited caption."
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
        expect(page).to have_content "Edited title"
        expect(page).to have_content "Edited caption."
        expect(page).to have_content itinerary_2.schedules[0].title
        expect(current_path).to eq post_path(id: post_1.id)
      end

      it "画像の変更に成功すること" do
        expect(page).to have_selector "img[src$='cat.jpg']"

        find("#delete_btn_0").click
        image_path = Rails.root.join('spec/fixtures/turtle.jpg')
        attach_file "post[photos_attributes][1][url]", image_path, make_visible: true
        click_on "投稿する"

        expect(page).to have_content "旅の思い出を更新しました。"
        expect(page).not_to have_selector "img[src$='cat.jpg']"
        expect(page).to have_selector "img[src$='turtle.jpg']"
      end
    end

    context "無効な値の場合" do
      it "必須項目が入力されていない場合、失敗すること" do
        find(".select-box").click
        find("option", text: "旅のプランを選択").click
        find("#delete_btn_0").click
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "旅のプランを選択してください"
        expect(page).to have_content "写真は1枚以上選択してください"
        expect(page).to have_content "タイトルを入力してください"
        expect(post_1.reload.itinerary_id).to eq post_1.itinerary_id
        expect(post_1.reload.photos).to eq post_1.photos
        expect(post_1.reload.title).to eq post_1.title
      end

      it "タイトルが空欄の場合、失敗すること" do
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "タイトルを入力してください"
        expect(post_1.reload.title).to eq post_1.title
      end

      it "タイトルが31文字以上の場合、失敗すること" do
        fill_in "post[title]", with: "a" * 31
        click_on "投稿する"

        expect(page).to have_content "タイトルは30文字以内で入力してください"
        expect(post_1.reload.title).to eq post_1.title
      end

      it "メモが1001文字以上入力された場合、「投稿する」ボタンが押せないこと" do
        fill_in "post[caption]", with: "a" * 1001

        expect(page).to have_content "1001"
        expect(find("#submit_btn")).to be_disabled
      end
    end
  end

  describe "削除", js: true do
    it "成功すること" do
      sign_in user
      expect {
        visit post_path(id: post_1.id)
        find("i", text: "more_horiz", visible: false).click
        click_on "削除"

        expect(page).to have_content "この投稿を削除しますか？この操作は取り消せません。"

        click_on "削除する"

        expect(page).to have_content "投稿を削除しました。"
        expect(page).not_to have_content post_1.title
        expect(current_path).to eq posts_path
      }.to change(Post, :count).by(-1)
    end
  end
end
