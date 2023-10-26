module Placeable
  extend ActiveSupport::Concern

  included do
    has_many :places, as: :placeable, dependent: :destroy
  end

  def user?
    instance_of? User
  end
end
