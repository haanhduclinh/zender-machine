require 'whatlanguage'

module Dl
  module TextAnalyzer
    class DetectLanguage
      def initialize
        @wl = WhatLanguage.new(:english)
      end

      def is_english?(text)
        @wl.language(text).to_s == 'english'
      end
    end
  end
end