class Place < ApplicationRecord
  attr_accessor :name, :address, :photo_url, :rating, :opening_hours, :phone_number, :url,
    :website, :error

  belongs_to :placeable, polymorphic: true

  validates :place_id, presence: true, uniqueness: { scope: [:placeable_type, :placeable_id] }
end
