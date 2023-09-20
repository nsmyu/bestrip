module GoogleApiConnectable
  extend ActiveSupport::Concern

  def get_place_details(place_id)
    uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json")
    http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = true

    params = [
      "?place_id=#{place_id}",
      "&fields=name%2Cformatted_address%2Cphotos",
      "&key=#{ENV['GOOGLE_API_KEY']}",
      "&language=ja&region=JP",
    ]

    req = Net::HTTP::Get.new(uri + params.join)
    response = http_client.request(req)
    data = JSON.parse(response.body, symbolize_names: true)

    if data[:error_message].blank?
      @place_name = data[:result][:name].to_s
      @place_address = data[:result][:formatted_address].to_s
      photo_reference = data[:result][:photos][0][:photo_reference]
      @place_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
    else
      @error_message = "スポット情報が取得できませんでした"
    end
  end
end
