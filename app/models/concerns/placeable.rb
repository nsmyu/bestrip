module Placeable
  extend ActiveSupport::Concern

  included do
    has_many :places, as: :placeable, dependent: :destroy
  end

  def user?
    instance_of? User
  end

  def added?(place_id)
    Place
      .where(placeable_type: self.class.to_s)
      .where(placeable_id: id)
      .where(place_id: place_id)
      .present?
  end
end
