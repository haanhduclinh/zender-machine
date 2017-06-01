require 'engtagger'

module Dl
  module TextAnalyzer
    class ETagger
      def initialize(text)
        @tagger = EngTagger.new
        @text_str = @tagger.add_tags(text)
      end

      def nound_phrases_hash
        res= @tagger.get_noun_phrases(@text_str)
        res ||= []
      end

      def adj_arr_hash
        @tagger.get_adjectives(@text_str)
      end
    end
  end
end
