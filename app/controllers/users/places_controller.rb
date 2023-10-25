class Users::PlacesController < PlacesController
  before_action :set_placeable,  except: %i[show]

  def create
    super
    @place_id = @place.place_id
  end

  def destroy
    super
    if request.referer&.end_with? "/places"
      redirect_to :user_places, notice: "お気に入りから削除しました。"
    end
  end

  private

  def set_placeable
    @placeable = User.find(params[:user_id])
  end
end
