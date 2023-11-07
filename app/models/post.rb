class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true

  validates :title, presence: true, length: { maximum: 30 }
  validates :caption, length: { maximum: 1000 }
  validates :photos, length: { minimum: 1, maximum: 20 }

  scope :has_keyword, -> (keyword, itinerary_with_keyword) do
    where("title LIKE?", "%#{keyword}%")
      .or(where("caption LIKE?", "%#{keyword}%"))
      .or(where(itinerary_id: [itinerary_with_keyword.pluck(:id)]).merge(where(itinerary_public: true)))
  end

  def has_saved_photos?
    return if !id
    Post.find(id).photos
  end
end
