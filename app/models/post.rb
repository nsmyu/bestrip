class Post < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :photos, dependent: :destroy

  validates :title, presence: true, length: { maximum: 30 }
  validates :caption, length: { maximum: 1000 }
  validates :photos, length: { minimum: 1, maximum: 20 }
end
