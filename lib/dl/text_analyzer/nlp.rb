## Config
# 1. Download full core - http://stanfordnlp.github.io/CoreNLP/
# 2. gem install stanford-core-nlp
# 3. gem environment # Check which directory to install
# 4. Extract all CONTENT in zip from step 1 to stanford-core-nlp/bin/
# 5. Download bridge
# 6. Install tagger
require 'stanford-core-nlp'

StanfordCoreNLP.use :english
StanfordCoreNLP.model_files = {}
StanfordCoreNLP.default_jars = [
  'joda-time.jar',
  'xom.jar',
  'stanford-corenlp-3.7.0.jar',
  'stanford-corenlp-3.7.0-models.jar',
  'jollyday.jar',
  'bridge.jar'
]

module Dl
  module TextAnalyzer
    class Nlp
      def initialize(text)
        @pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
        @annotaion = StanfordCoreNLP::Annotation.new(text)
        @pipeline.annotate(@annotaion)
      end

      def run!
        @annotaion.get(:sentences).each do |sentence|
        # Syntatical dependencies

        # puts sentence.get(:basic_dependencies).to_s

        sentence.get(:tokens).each do |token|
          # Default annotations for all tokens
          # puts token.get(:value).to_s
          text = token.get(:original_text).to_s
          # puts token.get(:character_offset_begin).to_s
          # puts token.get(:character_offset_end).to_s
          # POS returned by the tagger
          part_of_speech = token.get(:part_of_speech).to_s

          p "Text: #{text} - part of speed: #{part_of_speech}"
          # Lemma (base form of the token)
          # puts token.get(:lemma).to_s
          # Named entity tag
          # puts token.get(:named_entity_tag).to_s
          # Coreference
          # puts token.get(:coref_cluster_id).to_s
          # Also of interest: coref, coref_chain,
          # coref_cluster, coref_dest, coref_graph.
        end
      end
      end
    end
  end
end