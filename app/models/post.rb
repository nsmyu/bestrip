class Post < ApplicationRecord
  belongs_to :itinerary_users

  validates :title, presence: true, length: { maximum: 50 }
  validates :photos, presence: true
  validates :caption, length: { maximum: 1000 }

  mount_uploader :photos, PostPhotosUploader
end
