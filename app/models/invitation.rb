class Invitation < ApplicationRecord
  belongs_to :invited_to_itinerary, class_name: 'Itinerary', foreign_key: :itinerary_id
  belongs_to :invitee, class_name: 'User', foreign_key: :user_id
end
