class Users::EmailInvitationsController < Devise::InvitationsController
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, only: %i(new create)

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    existing_user = User.find_by(email: invite_params[:email])

    if existing_user
      if @itinerary.members.include?(existing_user)
        @already_added_error = "#{existing_user.name}さんはすでにメンバーに含まれています"
        return
      end

      self.resource = existing_user
      resource.send("currently_invited_to=", @itinerary.id)
      if resource.invite!(current_user)
        @itinerary.create_invitation(resource) if @itinerary.invitations.exclude?(resource)
        redirect_to itinerary_path(@itinerary.id), notice: "招待メールを#{resource.email}に送信しました。"
        return
      else
        respond_with resource, location: itinerary_path(@itinerary.id)
      end
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    if resource_invited
      @itinerary.create_invitation(resource)
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: itinerary_path(@itinerary.id)
    end
  end

  def edit
    invitation_code = params[:invitation_code]
    @invited_itinerary = Invitation.find_by(code: invitation_code)&.itinerary
    super
  end

  def update
    @invited_itinerary = Itinerary.find(params[:invited_itinerary_id])
    super
  end

  private

  def after_accept_path_for(resource)
    itineraries_path(invited_itinerary_id: @invited_itinerary.id)
  end

  def invite_resource
    super { |user| user.send("currently_invited_to=", @itinerary.id) }
  end
end
