require 'engtagger'

module Dl
  module TextAnalyzer
    class ETagger
      def initialize(text)
        @tagger = EngTagger.new
        @text_str = @tagger.add_tags(text)
      end

      def highscore_tag(limit: 10)
        nound_phrases_hash.sort_by { |_keyword, frequency| frequency }.take(limit)
      end

      def high_quality_keyword(limit: 10, min_frequency: 2, title: '')
        high_score_keyword_arr = highscore_tag(limit: limit).map do |keyword, frequency|
          keyword if frequency > min_frequency
        end

        @text_str = @tagger.add_tags(title)
        title_keyword_arr = highscore_tag(limit: limit).map { |keyword, _frequency| keyword }
        high_score_keyword_arr.compact & title_keyword_arr.compact
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
