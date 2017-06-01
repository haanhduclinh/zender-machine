require 'linkedin'
require 'pry'
require './lib/dl/log/dlfile'
require 'json'

module Dl
  module Social
    class LinkedinAdapter
      attr_accessor :consumer_key, :consumer_secret

      def initialize(consumer_key:, consumer_secret:)
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        @linkedin = LinkedIn::Client.new(consumer_key, consumer_secret)
        @linkedin = get_token
      end

      def share_post(title:, description:, submit_url:, submit_image_url:)
        post = {}
        post[:title] = title
        post[:description] = description
        post[:"submitted-url"] = submit_url
        post[:"submitted-image-url"] = submit_image_url
        
        res = @linkedin.add_share(content: post)
        res.code == "201"
      rescue => e
        p e
      end

      private

      def get_token
        if File.exist?('data_linkedin_token.store')
          data_token = Dl::Log::Dlfile.load_variant_from_file('data_linkedin_token.store')
          @linkedin.authorize_from_access(data_token[0], data_token[1])
        else
          request_token = @linkedin.request_token({}, scope: 'r_basicprofile r_emailaddress w_share')
          rtoken = request_token.token
          rsecret = request_token.secret

          res = request_token.authorize_url
          p "copy and paster to get pin #{res}"
          pin = gets
          data_token = @linkedin.authorize_from_request(rtoken, rsecret, pin)
          Dl::Log::Dlfile.store_variant_to_file(data_token, 'data_linkedin_token.store')
        end
        @linkedin
      end

    end
  end
end
