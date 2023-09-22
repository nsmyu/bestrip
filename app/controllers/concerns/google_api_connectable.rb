module GoogleApiConnectable
  extend ActiveSupport::Concern

  def get_place_details(place_id)
    uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json")
    http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = true
    uri.query = URI.encode_www_form({
      place_id: place_id,
      fields: "name,formatted_address,photos",
      key: ENV['GOOGLE_API_KEY'],
      language: "ja",
      region: "JP",
    })
    response = http_client.get(uri.request_uri)

    case response
    when Net::HTTPSuccess
      data = JSON.parse(response.body, symbolize_names: true)
      if data[:error_message].blank?
        @place_name = data[:result][:name].to_s
        @place_address = data[:result][:formatted_address].to_s
        photo_reference = data[:result][:photos][0][:photo_reference]
        @place_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
      else
        @error_message = "スポット情報を取得できませんでした（#{data[:error_message]}）"
      end
    else
      @error_message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
    end
  end
end
