class Users::InvitationsController < Devise::InvitationsController
  before_action :set_itinerary

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    existing_user = User.find_by(email: invite_params[:email])

    if existing_user
      if @itinerary.members.include?(existing_user)
        @already_added_error = "#{existing_user.name}はすでにメンバーに含まれています"
        return
      end
      existing_user.send("currently_invited_to=", @itinerary.id)
      existing_user.invite!(current_user)
      self.resource = existing_user
      Invitation.create(invitee: resource, invited_to_itinerary: @itinerary)
      redirect_to itinerary_path(@itinerary.id), notice: "招待メールが#{existing_user.email}に送信されました。"
      return
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    if resource_invited
      Invitation.create(invitee: resource, invited_to_itinerary: @itinerary)
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: itinerary_path(@itinerary.id)
    end
  end

  def update
    @itinerary = Itinerary.find(params[:itinerary_id])
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if resource.class.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        resource.after_database_authentication
        sign_in(resource_name, resource)
        respond_with resource, location: after_accept_path_for(@itinerary)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, location: new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with(resource)
    end
  end

  private

  def after_accept_path_for(itinerary)
    itineraries_path(invited_to_itinerary: itinerary.id)
  end

  def invite_resource
    set_itinerary
    super { |user| user.send("currently_invited_to=", @itinerary.id) }
  end
end
