class Users::InvitationsController < Devise::InvitationsController
  def new
    @itinerary = Itinerary.find(params[:itinerary_id])
    self.resource = resource_class.new
    render :new
  end

  def create
    @itinerary = Itinerary.find(params[:user][:latest_invitation_to])
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    @invitation = Invitation.new(invitee: resource, invited_to_itinerary: @itinerary)
    if !@invitation.save \
        && @invitation.errors[:invitee].include?("#{resource.name}さんはすでにメンバーに含まれています")
      return
    end

    if resource_invited
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: after_invite_path_for(@itinerary)
    end
  end

  private

  def after_invite_path_for(itinerary)
    itinerary_path(itinerary.id)
  end
end
