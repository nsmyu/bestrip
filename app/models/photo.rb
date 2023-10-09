class Photo < ApplicationRecord
  belongs_to :post
  validates :url, presence: true
  mount_uploader :url, PhotoUploader
end
