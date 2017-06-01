require 'pry'
require 'dotenv/load'
require 'config'
require 'faker'
require './lib/dl/mysql/adapter'
require './lib/dl/text_analyzer/high_score'
require './lib/dl/text_analyzer/eng_tagger'
require './lib/dl/zender_machine/detail_zender'

Config.load_and_set_settings(Config.setting_files("./config", ENV['Z_ENV']))

def build_data(title: ,author: ,description: ,tags_arr: [], header: ,thumbnail: ,content: ,author_url: ,public_date: ,categories: [])
  detail = Dl::Zender::DataClass::Detail.new
    detail.title = title
    detail.meta = {
      author: author,
      description: description
    }

    detail.post = {
      header: header,
      thumbnail: thumbnail,
      content: content,
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
      share: share,
    }
end

def build_description(content)
  shorter_str = content.split(" ").take(50).join(" ") + " ..."
  i = 0
  while shorter_str.length > 150
    i += 1
    shorter_str = content.split(" ").take(50 - i).join(" ") + " ..."
  end
  shorter_str
end

mysql = Dl::Mysql::Adapter.new(
  host: Settings.mysql.host,
  username: Settings.mysql.username,
  password: Settings.mysql.password,
  database: Settings.mysql.database,
)
zender = Dl::Zender::DetailZender.new(output_folder: './wwww/html/')
query = "SELECT * FROM wp_posts WHERE post_status='publish' LIMIT 100"
posts_data = mysql.query(query)

posts_data.each do |post|

  # "post_name"=>"what-occurs-from-web-server-to-web-browser"
  # post['post_name']
  display_name = Faker::Name.unique.name

  taggerable = Dl::TextAnalyzer::HighScore.new(post['post_content'])
  engtag = Dl::TextAnalyzer::ETagger.new(post['post_content'])

  categories_hash = []
  engtag.nound_phrases_hash.each do |cat|
    categories_hash << { name: cat, url: '#'}
  end

  data = build_data(
    title: post['post_title'],
    author: display_name,
    description: build_description(post['post_title']),
    tags_arr: taggerable.create_keywor_arr(10),
    header: '',
    thumbnail: '',
    content: post['post_content'],
    author_url: 'https://it-kn.com',
    public_date: post['post_date'],
    categories: categories_hash
  )
  
  zender.zending(data: data, url: post['post_name'])
  p "Done | #{post['post_title']}"
end