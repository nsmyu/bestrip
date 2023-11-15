module ItineraryUsersHelper
  def set_signed_in_user(user_type)
    if user_type == :owner
      sign_in user
    elsif user_type == :member
      itinerary.members << user
      sign_in user
    end
  end
end
