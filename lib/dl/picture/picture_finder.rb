require "net/http"
require "uri"
require "json"
require "ConnectSDK"

module Dl
  module Picture
    class PictureFinder
      def initialize(api, secret_key)
        @api_key = api
        @api_secret = secret_key
      end

      def get_picture_url(keyword)
        uri = URI.parse("https://api.gettyimages.com/v3/search/images?embed_content_only=true&exclude_nudity=true&fields=thumb&file_types=jpg&phrase=#{keyword}&sort_order=best_match")
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        req = Net::HTTP::Get.new(uri.path)
        req.add_field('Api-Key', @api)
        req.add_field('Accept', '*/*')

        res = https.request(req)
        picture_data = JSON.parse(res.body)
        picture_data['images']
      end

      def get_one_picture_pfinder(keyword)
        connectSdk = ConnectSdk.new(@api_key, @api_secret)
        search_results = connectSdk
            .search().images()
            .with_phrase(keyword)
            .with_page(1)
            .with_page_size(5)
            .execute()
        search_results['result_count'] > 0 ? search_results['images'].first['display_sizes'][0]['uri'] : nil
      end

      def create_picture_array(picture_data)
        result = []
        picture_data.each do |images|
          # p "title: #{images['title']}, url: #{images['display_sizes'][0]['uri']}"
          images['display_sizes'].each do |i|
            result << { is_watermarked: i['is_watermarked'] , url: i['uri'] }
          end
        end
        result
      end

      def self.create_image_html(img_url, title)
        "<img src='#{img_url}' title='#{title}' ></br>"
      end
    end
  end
end
