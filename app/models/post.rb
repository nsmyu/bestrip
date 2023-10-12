class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true, limit: 20

  validates :title, presence: true, length: { maximum: 30 }
  validates :caption, length: { maximum: 1000 }
  validates :photos, length: { minimum: 1, maximum: 20 }
end
