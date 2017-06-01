require "net/http"
require "uri"
require "open-uri"
require "json"
require 'pry'
module Dl
  module Wordpress
    class ApiJson
      def initialize(username: nil, password: nil, host: nil, use_ssl: false)
        @username = username
        @password = password
        @host = sprintf('http://%s', host)
        @host = sprintf('https://%s', host) if use_ssl
      end

      def cookie(username: nil, password: nil)
        username ||= @username
        password ||= @password
        query = sprintf('%s/api-v01/user/generate_auth_cookie/?username=%s&password=%s',
          @host,
          username,
          password
        )
        cookie_data = res_open_uri(url: query)
        cookie_data['cookie'] || false
      end

      def get_none_token
        query = sprintf('%s/api-v01/get_nonce/?controller=user&method=register', @host)
        res = res_open_uri(url: query)
        res['nonce'] || false
      end

      def register_user(username:, email:, display_name:, user_pass:)
        nonce = get_none_token
        query = sprintf('%s/api-v01/user/register/?username=%s&email=%s&nonce=%s&display_name=%s&notify=no&user_pass=%s',
          @host, username, email, nonce, display_name, user_pass)
        res = res_open_uri(url: query)
        res['status'] == 'ok' ? res : false
      rescue => e
        false
        # {
        #   "status"=>"ok",
        #   "cookie"=>
        #   "alanna@moriettejacobson.org|1491406478|TFGFNNwYq9VwFpkuR5XaBL5Rd2NMb0fnZeFDqZpdOgO|3ed48fab8fdeff37184b5e1ab190920b116f2aba26644749c67fa0904e8f7c8b",
        #   "user_id"=>12
        # }
      end

      def update_infor_cookie(cookie:, website:, city: nil, country:, skills:)
        query = sprintf('%s/api-v01/user/update_user_meta_vars/?cookie=%s&website=%s&city=%s&country=USA&skills=%s',
          @host, cookie, website, city, country, skills)
        res = res_open_uri(url: query)
        res['status'] == 'ok' ? res : false
      end

      def get_api_info(query:)
        uri = URI.parse(query)
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        req = Net::HTTP::Get.new(query)
        res = https.request(req)
        JSON.parse(res.body)
      end

      def res_open_uri(url: nil)
        url_encode = URI.escape(url)
        res = open(url_encode).read
        JSON.parse(res)
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