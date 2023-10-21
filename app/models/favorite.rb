class Favorite < ApplicationRecord
  belongs_to :user

  validates :place_id, presence: true, uniqueness: { scope: :user_id }
  validate :favorites_per_user_cannot_be_more_than_three_hundreds

  def favorites_per_user_cannot_be_more_than_three_hundreds
    if user && user.favorites.count >= 300
      errors.add(:user_id, "お気に入り登録上限の300件まで登録されているため、追加できません")
    end
  end
end
