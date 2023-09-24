module GoogleApiConnectable
  extend ActiveSupport::Concern

  def get_place_details(place_id)
    uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json")
    http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = true
    uri.query = URI.encode_www_form({
      place_id: place_id,
      fields: "name,formatted_address,photos,rating,opening_hours,international_phone_number,url,website",
      key: ENV['GOOGLE_API_KEY'],
      language: "ja",
      region: "JP",
    })
    response = http_client.get(uri.request_uri)

    case response
    when Net::HTTPSuccess
      data = JSON.parse(response.body, symbolize_names: true)
      if data[:error_message].blank?
        set_place_attributes(data)
      else
        @error_message = "スポット情報を取得できませんでした（#{data[:error_message]}）"
      end
    else
      @error_message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
    end
  end

  def set_place_attributes(data)
    @place_name = data[:result][:name]
    @place_address = data[:result][:formatted_address]
    @place_rating = data[:result][:rating]
    @place_opening_hours = data[:result][:opening_hours]
    @place_phone_number = data[:result][:international_phone_number]
    @place_url = data[:result][:url]
    @place_website = data[:result][:website]

    if data[:result][:photos]
      photo_references =  data[:result][:photos].map { |photo| photo[:photo_reference] }
      @place_photo_urls = photo_references.map do |photo_reference|
        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
      end
    end
  end
end
