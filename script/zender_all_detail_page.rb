require 'pry'
require 'dotenv/load'
require 'config'
require 'faker'
require './lib/dl/mysql/adapter'
require './lib/dl/text_analyzer/high_score'
require './lib/dl/text_analyzer/eng_tagger'
require './lib/dl/zender_machine/detail_zender'
require './lib/dl/article/text'

Config.load_and_set_settings(Config.setting_files("./config", ENV['Z_ENV']))
TITLE_LIMIT = Settings.seo.title_limit.freeze
DESCRIPTION_LIMIT = Settings.seo.description_limit.freeze

def build_data(title:, author:, tags_arr: [], thumbnail:, content:, author_url:, public_date:, categories: [])
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
    tags: tags_arr
  }

  share = Dl::Zender::DataClass::Share.new
  share.categories = categories.map do |category|
    { name: category[:name], url: category[:url] }
  end

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
  display_name = Faker::Name.unique.name

  taggerable = Dl::TextAnalyzer::HighScore.new(post['post_content'])
  engtag = Dl::TextAnalyzer::ETagger.new(post['post_content'])

  category_arr_from_text = engtag.high_quality_keyword(limit: 10, min_frequency: 1, title: post['post_title'])
  if category_arr_from_text.size.zero?
    category_arr_from_text = engtag.high_quality_keyword(limit: 10, min_frequency: 0, title: post['post_title'])
  end

  tag_arr = category_arr_from_text.map { |category_name, frequency| category_name }
  categories_arr = taggerable.create_keywor_arr(2).map do |highscore_object|
    { name: highscore_object.text, url: '/categorys/' + highscore_object.text }
  end

  data = build_data(
    title: post['post_title'],
    author: display_name,
    tags_arr: tag_arr,
    thumbnail: '',
    content: post['post_content'],
    author_url: 'https://it-kn.com',
    public_date: post['post_date'],
    categories: categories_arr
  )

  zender.zending(data: data, url: post['post_name'])
  p "Done | #{post['post_title']}"
end
