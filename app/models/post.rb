class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :replies, through: :comments
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true

  validates :title, presence: true, length: { maximum: 30 }
  validates :caption, length: { maximum: 1000 }
  validates :photos, length: { minimum: 1, maximum: 20 }

  scope :contains_keyword, -> (keyword) do
    where("title LIKE?", "%#{keyword}%").or(where("caption LIKE?", "%#{keyword}%"))
  end

  scope :belongs_to_itineraries_containing_keyword, -> (itineraries) do
    where(itinerary_id: [itineraries.pluck(:id)]).merge(where(itinerary_public: true))
  end

  def has_saved_photos?
    return if !id
    Post.find(id).photos
  end

  def liked_by?(user)
    return if !user
    likes.where(user_id: user.id).present?
  end
end
