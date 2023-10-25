class Place < ApplicationRecord
  belongs_to :placeable, polymorphic: true

  validates :place_id, presence: true, uniqueness: { scope: [:placeable_type, :placeable_id] }
end
