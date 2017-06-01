require 'lib/dl/q/common.rb'
require 'lib/dl/mysql/adapter'
require 'lib/dl/picture/cognitive'
require 'lib/dl/picture/bing'
require 'lib/dl/picture/picture_finder'
require 'lib/dl/picture/pixabay'
require 'lib/dl/text_analyzer/eng_tagger'
require 'lib/dl/text_analyzer/nlp'
require 'lib/dl/text_analyzer/high_score'
require 'lib/dl/text_analyzer/detect_language'
require 'lib/dl/social/linkedin_adapter'
require 'lib/dl/log/dlfile'
require 'lib/dl/article/text'
require 'lib/dl/content/content_creator'
require 'lib/dl/blogger/adapter'
require 'lib/dl/q/common'
require 'lib/dl/q/worker_initialize'
require 'lib/dl/control/dash_board'
require 'lib/dl/control/worker_heart'
require 'lib/dl/wordpress/poster'
require 'lib/dl/wordpress/api_json'
require 'lib/content_creater'
require 'pry'

module Dl
  module Control
    module WorkerHeart
      include Dl::Q
      include Dl::Article
      include Dl::Blogger
      include Dl::Content
      include Dl::Log
      include Dl::Mysql
      include Dl::Picture
      include Dl::Social
      include Dl::TextAnalyzer
      include Dl::Wordpress
    end
  end
end