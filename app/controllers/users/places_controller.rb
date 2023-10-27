class Users::PlacesController < PlacesController
  before_action :set_placeable, except: :show

  private

  def set_placeable
    @placeable = current_user
  end
end
