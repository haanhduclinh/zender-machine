require "net/http"
require "uri"
require "json"
require 'pry'
module Dl
  module Picture
    class Cognitive
      def initialize(api)
        @api = api
      end

      def get_picture_by_keyword(keyword)
        uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/images/search')
        uri.query = query_api(keyword)

        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Content-Type'] = 'multipart/form-data'
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = @api
        # Request body

        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        JSON.parse(response.body)
      end

      def get_one_picture_by_keyword(keyword)
        picture_data = get_picture_by_keyword(keyword)
        picture_data['value'].count.zero? ? nil : format("%s%s", picture_data['value'][0]['thumbnailUrl'],
          file_format(picture_data['value'][0]['encodingFormat'])
        )
      end

      private

      def file_format(type)
        if ['jpeg', 'jpg', 'JPG'].include? type
          '.jpg'
        elsif ['png', 'PNG'].include? type
          '.png'
        else
          format(".%s", type)
        end
      end

      def query_api(keyword)
        URI.encode_www_form({
            'q' => keyword,
            'count' => '10',
            'offset' => '0',
            'mkt' => 'en-us',
            'safeSearch' => 'Moderate'
        })
      end
    end
  end
end