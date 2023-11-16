module ItineraryUsersHelper
  def set_signed_in_user(user_type)
    if user_type == :member
      itinerary.members << user
    end
    sign_in user
  end
end
