RSpec.describe "Likes", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: other_user) }
  let!(:test_post) { create(:post, :caption_great_with_hashtag, :with_photo, itinerary: itinerary) }

  before do
    sign_in user
  end

  describe "いいね", js: true, focus: true do
    it "投稿に「いいね」ができること（「いいね」作成フォームが削除リンクに切り替わること）" do
      visit post_path(id: test_post.id)

      expect {
        find(:xpath, "//form[button[i[contains(text(), 'thumb_up')]]]").click

        expect(page).to have_xpath "//a[i[contains(text(), 'thumb_up')]]"
      }.to change(Like, :count).by(1)
    end

    it "投稿につけた「いいね」を削除できること（「いいね」削除リンクが作成フォームに切り替わること）" do
      create(:like, post: test_post, user: user)
      visit post_path(id: test_post.id)

      expect {
        find(:xpath, "//a[i[contains(text(), 'thumb_up')]]").click
        expect(page).to have_xpath "//form[button[i[contains(text(), 'thumb_up')]]]"
      }.to change(Like, :count).by(-1)
    end
  end
end
