class ApplicationController < ActionController::Base
  private

  def authenticate_itinerary_member(itinerary)
    redirect_to :root if itinerary.members.exclude?(current_user)
  end

  def set_itinerary
    if params[:itinerary_id]
      @itinerary = Itinerary.find(params[:itinerary_id])
    else
      @itinerary = Itinerary.find(params[:id])
    end
  end

  def sort_schedules_by_date_time(schedules)
    date_sorted_schedules = schedules.order(:schedule_date)
    @date_time_sorted_schedules = date_sorted_schedules
    .group_by(&:schedule_date)
    .map do |date, schedules|
      [
        date,
        schedules.partition { |s| s.start_at.nil? }.yield_self do |nils, with_start_at|
          with_start_at.sort_by { |w| w.start_at.strftime("%H:%M") } + nils
        end,
      ]
    end
  end

  def get_place_details(place_id)
    query_params = GooglePlacesApi::Request.new(place_id)
    result = query_params.request

    case result
    when Hash
      if result[:error_message].blank?
        @place_details = GooglePlacesApi::Request.attributes_for(result)
        set_photo_urls(@place_details[:photos]) if @place_details[:photos]
      else
        @error = "スポット情報を取得できませんでした（#{result[:error_message]})"
      end
    else
      @error = "スポット情報を取得できませんでした（#{result})"
    end
  end

  def set_photo_urls(place_photos)
    photo_references =  place_photos.pluck(:photo_reference)
    @place_photo_urls = photo_references.map do |photo_reference|
      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
    end
  end
end
