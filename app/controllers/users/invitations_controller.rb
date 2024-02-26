class Users::InvitationsController < Devise::InvitationsController
  before_action :set_itinerary, except: :create
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, only: :create

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    existing_user = User.find_by(email: invite_params[:email])

    if existing_user
      if @itinerary.members.include?(existing_user)
        @already_added_error = "#{existing_user.name}さんはすでにメンバーに含まれています"
        return
      end
      existing_user.send("currently_invited_to=", @itinerary.id)
      existing_user.invite!(current_user)
      self.resource = existing_user
      @itinerary.pending_invitations.create(user: resource)
      redirect_to itinerary_path(@itinerary.id), notice: "招待メールを#{existing_user.email}に送信しました。"
      return
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    if resource_invited
      @itinerary.pending_invitations.create(user: resource)
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      respond_with resource, location: itinerary_path(@itinerary.id)
    end
  end

  def edit
    @invitation_token = params[:invitation_token]
    digest = Devise.token_generator.digest(User, :invitation_token, params[:invitation_token])
    user = User.find_by(invitation_token: digest)
    if user&.name != "newly_invited"
      redirect_to new_user_session_path(invitation_token: params[:invitation_token],
                                        itinerary_id: params[:itinerary_id])
      return
    end
    super
  end

  private

  def after_accept_path_for(resource)
    itineraries_path(invited_itinerary_id: @itinerary.id)
  end

  def invite_resource
    super { |user| user.send("currently_invited_to=", @itinerary.id) }
  end
end
