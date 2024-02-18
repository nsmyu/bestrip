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

  private

  def after_invite_path_for(itinerary)
    itinerary_path(itinerary.id)
  end

  def after_accept_path_for(resource)
    itineraries_path
  end
end
