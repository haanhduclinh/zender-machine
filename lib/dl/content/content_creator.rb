require "net/http"
require "uri"
require "json"
module Dl
  module Content
    class ContentCreator
      attr_reader :api_key,:email

      def initialize(data)
        @api_key = data[:api_key]
        @email = data[:email_address]
      end
      def action(action='api_quota',text=nil,option={})
        # unique_variation
        uri = URI.parse('http://www.spinrewriter.com/action/api')
        https = Net::HTTP.new(uri.host,uri.port)

        req = Net::HTTP::Post.new(uri.path)
        data = Hash.new
        data[:action] = action
        data[:api_key] = @api_key
        data[:email_address] = @email
        data[:text] = text

        option.each { |k,v| data[k] = v }

        req.set_form_data(data)
        res = https.request(req)
        res_data = JSON.parse(res.body)
        res_data["response"]
      end
    end
  end
end