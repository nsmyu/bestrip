class Place < ApplicationRecord
  belongs_to :placable, polymorphic: true

  validates :place_id, presence: true, uniqueness: { scope: [:placable_type, :placable_id] }
end
