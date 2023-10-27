class Place < ApplicationRecord
  attr_accessor :name, :address, :photo_url, :rating, :opening_hours, :phone_number, :url,
    :website, :error

  belongs_to :placeable, polymorphic: true

  validates :place_id, presence: true, uniqueness: { scope: [:placeable_type, :placeable_id] }
  validate :places_per_placeable_cannot_be_more_than_three_hundreds

  def places_per_placeable_cannot_be_more_than_three_hundreds
    if Place.where(placeable_id: placeable_id).where(placeable_type: placeable_type).count >= 300
      errors.add(:placeable_id, "スポットの登録数が上限に達しています")
    end
  end
end
