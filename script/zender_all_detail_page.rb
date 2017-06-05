require 'pry'
require 'dotenv/load'
require 'config'
require 'faker'
require './lib/dl/mysql/adapter'
require './lib/dl/text_analyzer/high_score'
require './lib/dl/text_analyzer/eng_tagger'
require './lib/dl/zender_machine/detail_zender'
require './lib/dl/article/text'
require 'fastimage'
require 'time'

Config.load_and_set_settings(Config.setting_files("./config", ENV['Z_ENV']))
TITLE_LIMIT = Settings.seo.title_limit.freeze
DESCRIPTION_LIMIT = Settings.seo.description_limit.freeze
TAG_LIMIT = 10
MIN_FREQUENCY = 0
HIGH_QUALITY_FREQUENCY = 1
CATEGORY_LIMIT = 20
FOOTER_RELATED_LIMIT = 20

def build_data(title:, author:, tags_arr: [], thumbnail:, content:, author_url:, public_date:, categories: [], footer_relate_arr: [])
  detail = Dl::Zender::DataClass::Detail.new

  detail.meta = {
    title: build_seo(title, TITLE_LIMIT),
    author: author,
    description: build_seo(content, DESCRIPTION_LIMIT)
  }

  detail.post = {
    title: title,
    thumbnail: thumbnail,
    content: Dl::Article.text_to_html(content),
    author: author,
    author_url: author_url,
    public_date: public_date,
    tags: tags_arr,
    right_related: footer_relate_arr.first(6)
  }

  share = Dl::Zender::DataClass::Share.new
  share.categories = categories.map do |category|
    { name: category[:name], url: category[:url] }
  end
  share.footer_categories =  footer_relate_arr.last(3)

  {
    data: detail,
    share: share
  }
end

def build_seo(content, limit)
  shorter_str = content.split(' ').take(30).join(' ')
  i = 0
  while shorter_str.length > limit
    i += 1
    shorter_str = content.split(' ').take(30 - i).join(' ')
  end
  shorter_str
end

def thumbnail_by_id(mysql_obj:, id:)
  thumbnail_data = mysql_obj.query("SELECT meta_value from wp_postmeta WHERE post_id=#{id} AND meta_key='_wp_attached_file'")
  if thumbnail_data.size > 0
    "http://storage.googleapis.com/it-kn-media-prod/" + thumbnail_data.first['meta_value']
  else
    nil
  end
end

def post_ids_by_keyword(mysql_obj:, keywords: [], limit: 3)
  footer_related_link = mysql_obj.query("SELECT ID,post_title,post_name,post_date FROM wp_posts WHERE post_content REGEXP '#{keywords.join('|')}' LIMIT #{limit + 5}")
  filtered_footer = footer_related_link.to_a.uniq! {|k,v| k['post_title']}
  if filtered_footer.size > 0
    filtered_footer.take(limit).map do |post|
      {
        name: post['post_title'],
        url: post['post_name'],
        thumbnail: thumbnail_by_id(
          mysql_obj: mysql_obj,
          id: post['ID']
        ),
        post_date: post['post_date'],
      }
    end
  else
    []
  end
end

mysql = Dl::Mysql::Adapter.new(
  host: Settings.mysql.host,
  username: Settings.mysql.username,
  password: Settings.mysql.password,
  database: Settings.mysql.database
)
zender = Dl::Zender::DetailZender.new(output_folder: './www/html')
query = "SELECT * FROM wp_posts WHERE post_status='publish' LIMIT 10"
posts_data = mysql.query(query)

posts_data.each do |post|
  # "post_name"=>"what-occurs-from-web-server-to-web-browser"
  # post['post_name']
  
  thumbnail_data = thumbnail_by_id(mysql_obj: mysql, id:post['ID'])

  display_name = Faker::Name.unique.name

  taggerable = Dl::TextAnalyzer::HighScore.new(post['post_content'])
  engtag = Dl::TextAnalyzer::ETagger.new(post['post_content'])

  category_arr_from_text = engtag.high_quality_keyword(limit: TAG_LIMIT, min_frequency: HIGH_QUALITY_FREQUENCY, title: post['post_title'])
  if category_arr_from_text.size.zero?
    category_arr_from_text = engtag.high_quality_keyword(limit: TAG_LIMIT, min_frequency: MIN_FREQUENCY, title: post['post_title'])
  end

  tag_arr = category_arr_from_text.map { |category_name, frequency| category_name.gsub(/[^a-zA-Z. ]/, "") }
  categories_arr = taggerable.create_keywor_arr(CATEGORY_LIMIT).map do |highscore_object|
    name = highscore_object.text.gsub(/[^1-9a-zA-Z ]/, "")
    if name && !name.empty?
      { name: name, url: '/categorys/' + name }
    end
  end

  # build related link
  footer_related_arr = post_ids_by_keyword(mysql_obj: mysql, keywords: tag_arr, limit: FOOTER_RELATED_LIMIT)

  data = build_data(
    title: post['post_title'],
    author: display_name,
    tags_arr: tag_arr,
    thumbnail: thumbnail_data,
    content: post['post_content'],
    author_url: 'https://it-kn.com',
    public_date: post['post_date'],
    categories: categories_arr.compact,
    footer_relate_arr: footer_related_arr
  )

  zender.zending(data: data, url: post['post_name'])
  p "Done | #{post['post_title']}"
end
