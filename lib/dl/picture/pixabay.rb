require "net/http"
require "uri"
require "json"
require 'pry'
module Dl
  module Picture
    class Pixabay

      def initialize(api)
        @api = api
      end

      def get_picture_by_keyword(keyword)
        query = query_api(
          keyword: keyword
        )
        uri = URI.parse(query)
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        req = Net::HTTP::Get.new(query)
        res = https.request(req)
        picture_data_arr = JSON.parse(res.body)
        return [] if picture_data_arr['totalHits'].zero?
        picture_data_arr['hits']
      rescue JSON::ParserError, Net::ReadTimeout => ex
        []
      end

      def get_one_picture(keyword)
        res = get_picture_by_keyword(keyword)
        res.count.zero? ? nil : res.first['webformatURL']
      end

      def get_picture_hash(keyword)
        return_arr = []
        get_picture_by_keyword(keyword).each_with_object({}) do |keyword,result|
          result[:picture_url] = keyword['webformatURL']
          result[:height] = keyword['webformatHeight']
          result[:width] = keyword['webformatWidth']
          result[:tags] = keyword['tags']
          return_arr << result
        end
        return_arr
      end

      private

      def query_api(keyword: ,min_width: 250, min_height: 250, order: 'popular', safesearch: true)
        "https://pixabay.com/api/?key=#{@api}&q=#{URI.encode(keyword)}&image_type=photo&min_width=#{min_width}&min_height=#{min_height}&order=#{order}&safesearch=#{safesearch}&pretty=true"
      end

      def create_arr(picture_data)
        picture_data.each_with_object([]){|picture, result| result << picture['webformatURL'] }
      end
    end
  end
end