require 'pry'
require './lib/dl/q/common.rb'

Dl::Q.load_lib('./lib/dl/')

module Dl
  module Control
    class DashBoard

      def initialize(picture_api = {}, content_api = {})
        @content = Dl::Content::ContentCreator.new(api_key: content_api[:api_key], email_address: content_api[:email_address])
        @picture = Dl::Picture::PictureFinder.new(picture_api[:pic_api], picture_api[:pic_secret])
        @wp = Dl::Wordpress::Poster.new(content_api[:host_name], content_api[:username], content_api[:password], content_api[:use_ssl])
        @mysql = Dl::Mysql::Adapter.new(
          host: content_api[:mysql_host] ,
          username: content_api[:mysql_username] ,
          password: content_api[:mysql_password],
          database: content_api[:mysql_database]
        )
        @pixa = Dl::Picture::Pixabay.new(content_api[:pixa_api])
      end

      def create_content_from_source(text, action ="unique_variation")
        @content.action("unique_variation",text)
      end

      def get_media_item(img_id)
        @wp.get_media_item(img_id)
      end

      def check_quote
        @content.action("api_quota")
      end

      def read_file_encode(file_path)
        Dl::Article.read_file_encode(file_path)
      end

      def get_embeded_text_from_file(file_name_txt)
        article = Dl::Article.read_file_encode(file_name_txt)
        type = Dl::Article.check_format(article)
        if type
          encode_data = Dl::Article.progress_tex(type, article)
          article_hash = Dl::Article.create_hash_return(article , encode_data)
          title = article_hash[:title]
          text = article_hash[:content]
        else
          article_hash = Dl::Article.extract_article_spec(file_name_txt)
          title_unfilter = File.basename(file_name_txt, '.txt')
          title = Dl::Q.remove_underline(title_unfilter)
          text = article
        end

        embeded_text = title + "\n" + text
      end

      def create_content_from_file(file_name_txt)
        embeded_text = get_embeded_text_from_file(file_name_txt)
        create_content_from_source(embeded_text)
      end

      def extract_content_from_data(data)
        result = {}
        result[:title] = data.lines.first.chomp
        result[:content] = Dl::Q.remote_first(data)
        result
      end

      def create_pic_arr_with_keyword(keyword)
        @picture.get_picture_url(keyword)
      end

      def get_one_picture_pfinder(keyword)
        @picture.get_one_picture_pfinder(keyword)
      end

      def high_score_keyword_arr(text, limit_int = nil)
        if limit_int
          arr = text_analyzer(text, limit_int)
        else
          arr = text_analyzer(text)
        end
        arr.each_with_object([]){|keyword_obj, result| result << keyword_obj.text }
      end

      def store(variant, path = nil)
        Dl::Log::Dlfile.store_variant_to_file(variant, path)
      end

      def load(path)
        Dl::Log::Dlfile.load_variant_from_file(path)
      end

      def table_log(start_time)
        Dl::Log::Dlfile.table_status(start_time)
      end

      # Tag arr = combie EngTag + HighScore
      def create_tag_arr(text, high_score_limit_int = 10, limit_tag_arr = nil)
        tag_score_arr = create_tag_score_arr(text)

        high_score_arr = high_score_keyword_arr(text, high_score_limit_int)
        return [] if tag_score_arr.count == 0
        tag_arr = []
        filter_arr = tag_score_arr.select { |keyword, count| keyword.length > 5 && Dl::Q.en_uppercase?(keyword) }
        filter_arr.each {|keyword, _| tag_arr << keyword.downcase if array_include_key?(keyword, high_score_arr) }

        limit_tag_arr ? tag_arr.take(limit_tag_arr) : tag_arr
      end

      def nlp(text)
        Dl::TextAnalyzer::Nlp.new(text).run!
      end

      def post_article(date: Time.now, title:, content:, post_url:, author_id:, category_arr:, tag_arr:, attachment_id:)
        @wp.post(date: date,
          title: title,
          content: content,
          post_url: post_url,
          author_id: author_id,
          category_arr: category_arr,
          tag_arr: tag_arr,
          attachment_id: attachment_id
        )
      end

      def create_thumb_from_title(title)
        thum_arr = create_pic_arr_with_keyword(title)
        result = thum_arr.count > 0 ? thum_arr[0]['display_sizes'][0]['uri'] : nil
      end

      def create_img_html(img_url, title)
        Dl::Picture::PictureFinder.create_image_html(img_url, title)
      end

      def insert_data_to_mysql(hash_data)
        @mysql.insert_query(hash_data)
      end

      def duplicate?(table, origin_url)
        return nil if origin_url.nil?
        @mysql.check_duplicate(table, origin_url)
      end

      def get_post(table)
        @mysql.get_post(table)
      end

      def get_post_by_keyword(table_name, keyword_str)
        args = keyword_str.split(',')
        @mysql.get_post_by_keyword(table_name, *args)
      end

      def update_is_publish(table, id)
        @mysql.update_is_publish(table, id)
      end

      def upload_image(image_file_path, default_picture_id = nil)
        @wp.upload_image(image_file_path, default_picture_id)
      end

      def get_nound_from_text(text)
        engtag = Dl::TextAnalyzer::ETagger.new(text)
        engtag.nound_phrases_hash
      end

      def get_all_post_id(table)
        conditon = "ORDER BY id ASC"
        @mysql.load_all_id_title(conditon, table)
      end

      def get_one_picture_from_keyword_pixa(keyword)
        @pixa.get_one_picture(keyword)
      end

      def update_picture_url(image_url:, table:, id:)
        @mysql.update_picture_url(image_url, table, id)
      end

      def retry_picture(keyword_arr: , times: 1, sleep_time_int: 3)
        keyword_arr.each do |keyword|
          picture_url = retry_get_picture(keyword: keyword, times: times, sleep_time_int: sleep_time_int)
          return picture_url if picture_url
        end
        return nil
      end

      def load_fixer(table)
        @mysql.load_fixer(table)
      end

      def update_fixer(text, table, id)
        @mysql.update_fixer(text, table, id)
      end

      def get_post_by_id(table,id)
        res = @mysql.get_post_by_id(table, id)
        res.first
      end

      def detect_error_data(article)
        type = Dl::Article.check_format(article)
        if type
          encode_data = Dl::Article.progress_tex(type, article)
          article_hash = Dl::Article.create_hash_return(article , encode_data)
          title = article_hash[:title]
          article = article_hash[:content]
        end
        article
      end

      def valid?(text)
        language = Dl::TextAnalyzer::DetectLanguage.new
        language.is_english?(text)
      end

      def load_all_db(table)
        @mysql.load_all_db(table)
      end

      def retry_pfinder(keyword_arr: ,times: 1, sleep_time_int: 0)
        keyword_arr.each do |keyword|
          image_url = retry_get_pfinder(keyword: keyword, times: times, sleep_time_int: sleep_time_int)
          return image_url if image_url
        end
        nil
      end

      private

      def text_analyzer(text, limit_int = 20)
        text_analyzer = Dl::TextAnalyzer::HighScore.new(text)
        keyword_arr = text_analyzer.create_keywor_arr(limit_int)
      end

      def array_include_key?(keyword, arr)
        arr.any? {|k| keyword.downcase.include?(k.downcase) }
      end

      def create_tag_score_arr(text)
        noun_arr = get_nound_from_text(text)
        tag_arr = []
        return [] if noun_arr.count == 0
        sort_arr_tag = noun_arr.sort_by { |key, count| count }
        sort_arr_tag.each {|key,_| tag_arr << key }
      end

      def retry_get_picture(keyword: ,times: 1, sleep_time_int: 0)
        return nil if keyword.include?(' ') == false
        input_picture = nil
        i = 0
        keyword.split.each do |keyword_element|
          sleep(sleep_time_int)
          input_picture = get_one_picture_from_keyword_pixa(keyword_element)
          i += 1
          return input_picture if(input_picture || i >= times)
        end
        input_picture
      end

      def retry_get_pfinder(keyword: ,times: 1, sleep_time_int: 0)
        return nil if keyword.include?(' ') == false
        i = 0
        input_picture = nil
        keyword.split.each do |keyword_element|
          sleep(sleep_time_int)
          input_picture = get_one_picture_pfinder(keyword_element)
          i += 1
          return input_picture if(input_picture || i >= times)
        end
        input_picture
      end
    end
  end
end