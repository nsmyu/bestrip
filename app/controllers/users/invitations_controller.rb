class Users::InvitationsController < Devise::InvitationsController

  def new
    @itinerary = Itinerary.find(params[:itinerary_id])
    self.resource = resource_class.new
    render :new
  end

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      resource.invited_to_itineraries << @itinerary
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: self.resource.email
      end
      if self.method(:after_invite_path_for).arity == 1
        respond_with resource, location: after_invite_path_for(@itinerary)
      else
        respond_with resource, location: after_invite_path_for(@itinerary, resource)
      end
    end
  end
  private

  def after_invite_path_for(itinerary, invitee = nil)
    itinerary_path(itinerary.id)
  end
end
