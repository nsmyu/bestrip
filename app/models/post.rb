class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user

  validates :title, presence: true, length: { maximum: 30 }
  validates :photos, presence: true
  validates :caption, length: { maximum: 1000 }

  mount_uploader :photos, PostPhotosUploader
end
