require 'auto_html'
require 'pry'

module Dl::Article
  module_function

    def extract_article_spec(file_name)
      result = {}

      a = read_file_encode(file_name)
      title_pos = a.index('Title:')
      wordcount_pos = a.index('Word Count:')

      summary_post = a.index('Summary:')
      keyword_pos = a.index('Keywords:')
      body_pos = a.index('Article Body:')


      title = a[0..wordcount_pos]
      word_count = a[wordcount_pos..summary_post]
      keyword = a[keyword_pos..body_pos]
      summary = a[summary_post..keyword_pos]
      content = a[body_pos..-1]

      result[:title] = get_content_from_article('Title:', title)
      result[:word_count] = get_content_from_article('Word Count:', word_count)
      result[:keyword] = get_content_from_article('Keywords:', keyword)
      result[:summary] = get_content_from_article('Summary:', summary)
      result[:content] = get_content_from_article('Article Body:', content)

      result
    end

    def normal_file?(file_name)
      a = read_file_encode(file_name)
      title_pos = a.index('Title:')
      if title_pos
        title_pos < 500 ? nil : true
      else
        true
      end
    end

    def read_file_encode(file_name)
      File.read(file_name).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
    end

    def get_content_from_article(title, article)
      res = article[title.length...-1]
      res.strip
    end

    def load_formats_arr
      Dir["./config/format/**/*.yml"]
    end

    def check_format(article)
      type = nil # normal
      load_formats_arr.each do |dl_format|
        check_format = YAML.load_file(dl_format)
        format_conditions = check_format['format']
        res_arr = []
        pos_hash = {}

        format_conditions.each do |condition|

          check_text = condition['text']
          less_than = condition['postion_less_than']
          bigger_than = condition['postion_bigger_than']
          length_limit = condition['length']
          row_post = condition['row']

          kq = check_text_less_than(article, check_text, less_than)\
          && check_text_bigger_than(article, check_text, bigger_than)\
          && check_pos_line(article, check_text, row_post)

          res_arr << kq
        end
        return type = check_format['name'] if res_arr.all? { |condition| condition == true }
      end
      nil
    end

    def check_text_less_than(article, text, less_than)
      return true if less_than == 0 || less_than === nil
      return nil unless article.index(text)
      article.index(text) <= less_than
    end

    def check_text_bigger_than(article, text, bigger_than)
      return true if bigger_than == 0 || bigger_than === nil
      return nil unless article.index(text)
      article.index(text) >= bigger_than
    end

    def check_pos_line(article, text, row_post)
      return true if row_post == 0 || row_post == nil
      post_text = article.index(text)
      if post_text
        post_count = article[0..post_text].lines.count || 0
        post_count == row_post
      else
        nil
      end
    end

  # [
  #   [title, 0, 100],
  #   [content, 100, 200]
  # ]
    def progress_tex(type, article)
      load_return = YAML.load_file("./config/format/#{type}.yml")
      return_fields = load_return['return']
      res_arr = []
      return_fields.each do |field|
        elemenent_arr = []
        elemenent_arr << field['text']
        elemenent_arr << article.index(field['text']) + field['text'].length
        res = field['end_text'] ? article.index(field['end_text']) - 1 : -1
        elemenent_arr << res
        res_arr << elemenent_arr
      end
      res_arr
    end

    def create_hash_return(article , result_encode )
      article_hash = {}

      title_start_point = result_encode[0][1]
      title_end_point = result_encode[0][2]
      article_hash[:title] = article[title_start_point..title_end_point].strip

      content_start_point = result_encode[1][1]
      content_end_point = result_encode[1][2]
      article_hash[:content] = article[content_start_point..content_end_point].strip

      article_hash
    end

    def text_to_html(text)
      simple_format = AutoHtml::SimpleFormat.new
      # base_format = AutoHtml::Pipeline.new(simple_format)
      simple_format.call(text)
    end
end