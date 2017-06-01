require "net/http"
require "uri"
require "json"
require 'pry'

require "bing-search"

module Dl
  module Picture
    class Bing
      def initialize(account_key)
        BingSearch.account_key = account_key
      end

      def get_picture_by_keyword(keyword)
        res = BingSearch.image(keyword).class
      end

    end
  end
end