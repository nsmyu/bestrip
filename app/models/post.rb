class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true

  validates :title, presence: true, length: { maximum: 30 }
  validates :caption, length: { maximum: 1000 }
  validates :photos, length: { minimum: 1, maximum: 20 }

  def has_photos?
    return if !id
    Post.find(id).photos
  end
end
