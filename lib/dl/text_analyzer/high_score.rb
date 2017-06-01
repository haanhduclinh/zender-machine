# require 'steammer'
require 'highscore'

module Dl
  module TextAnalyzer
    class HighScore
      def initialize(text)
        @highscore = Highscore::Content.new(text)
        @highscore.configure do
          set :multiplier, 2
          set :upper_case, 3
          set :long_words, 2
          set :long_words_threshold, 15
          set :short_words_threshold, 3      # => default: 2
          set :bonus_multiplier, 2           # => default: 3
          set :vowels, 1                     # => default: 0 = not considered
          set :consonants, 5                 # => default: 0 = not considered
          set :ignore_case, true             # => default: false
          set :word_pattern, /[\w]+[^\s0-9]/ # => default: /\w+/
          set :stemming, true                # => default: false
        end
      end

      def create_keywor_arr(limit = 10)
        @highscore.keywords.top(limit)
      end
    end
  end
end