class Users::InvitationsController < Devise::InvitationsController
  def new
    @itinerary = Itinerary.find(params[:itinerary_id])
    self.resource = resource_class.new
    render :new
  end

  def create
    @itinerary = Itinerary.find(params[:user][:latest_invitation_to])
    existing_user = User.where(email: invite_params[:email])[0]

    if existing_user && !@itinerary.members.include?(existing_user)
      existing_user.update(invite_params)
      existing_user_invited = existing_user.invite!(current_user)
      self.resource = existing_user
      Invitation.create(invitee: resource, invited_to_itinerary: @itinerary)
      redirect_to itinerary_path(@itinerary.id), notice: "招待メールが#{existing_user.email}に送信されました。"
      return
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    @invitation = Invitation.new(invitee: resource, invited_to_itinerary: @itinerary)
    if !@invitation.valid? \
        && @invitation.errors[:invitee].include?("#{resource.name}さんはすでにメンバーに含まれています")
    end

    if resource_invited
      @invitation.save
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: after_invite_path_for(@itinerary)
    end
  end

  def edit
    @itinerary = Itinerary.find(params[:itinerary_id])
    super
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

  def after_invite_path_for(itinerary)
    itinerary_path(itinerary.id)
  end

  def after_accept_path_for(itinerary)
    itineraries_path(invited_to_itinerary: itinerary.id)
  end
end
