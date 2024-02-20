class Users::InvitationsController < Devise::InvitationsController
  before_action :set_itinerary

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    existing_user = User.find_by(email: invite_params[:email])

    if existing_user
      if @itinerary.members.include?(existing_user)
        @already_added_error = "#{existing_user.name}さんはすでにメンバーに含まれています"
        return
      end
      existing_user.send("registration_completed=", !!existing_user.invitation_accepted_at)
      existing_user.send("currently_invited_to=", @itinerary.id)
      existing_user.invite!(current_user)
      self.resource = existing_user
      PendingInvitation.create(invitee: resource, invited_to_itinerary: @itinerary)
      redirect_to itinerary_path(@itinerary.id), notice: "招待メールが#{existing_user.email}に送信されました。"
      return
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    if resource_invited
      PendingInvitation.create(invitee: resource, invited_to_itinerary: @itinerary)
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: itinerary_path(@itinerary.id)
    end
  end

  private

  def after_accept_path_for(resource)
    itineraries_path(invited_to_itinerary: @itinerary.id)
  end

  def invite_resource
    super { |user| user.send("currently_invited_to=", @itinerary.id) }
  end
end
