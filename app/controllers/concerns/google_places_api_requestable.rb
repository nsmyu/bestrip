module GooglePlacesApiRequestable
  extend ActiveSupport::Concern

  class Request
    def initialize(place_id, with_photos)
      @query = URI.encode_www_form({
        place_id: place_id,
        fields:
          "name,formatted_address,rating,opening_hours,url,website#{ ",photos" if with_photos }",
        key: ENV['GOOGLE_API_KEY'],
        language: "ja",
        region: "JP",
      })
    end

    def request
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json")
      http_client = Net::HTTP.new(uri.host, uri.port)
      http_client.use_ssl = true
      uri.query = @query
      response = http_client.get(uri.request_uri)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body, symbolize_names: true)
      else
        "HTTP ERROR: code=#{response.code} message=#{response.message}"
      end
    end
  end
end
