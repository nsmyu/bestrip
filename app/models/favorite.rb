class Favorite < ApplicationRecord
  belongs_to :user

  validates :place_id, presence: true, uniqueness: { scope: :user_id }
  validate :favorites_per_user_cannot_be_more_than_three_hundreds

  def favorites_per_user_cannot_be_more_than_three_hundreds
    if user && user.favorites.count >= 300
      errors.add(:user_id, "ひとつの旅のプランにつき、行きたい場所リストへの登録は300件までです")
    end
  end
end
