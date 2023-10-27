class Users::PlacesController < PlacesController
  before_action :set_placeable, except: :show

  def destroy
    super
    if request.referer&.end_with?("/places") && @placeable.places.count.zero?
      redirect_to :users_places, notice: "スポットを削除しました。"
    end
  end

  private

  def set_placeable
    @placeable = current_user
  end
end
