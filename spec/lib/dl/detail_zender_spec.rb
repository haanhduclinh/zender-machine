require 'spec_helper'
require './lib/dl/zender_machine/detail_zender'

RSpec.describe Dl::Zender::DetailZender do

  describe '#DetailZender' do

  let(:html_file) {'./www/html/234.html'}
  let(:sample_thumb) {'http://dreamicus.com/data/image/image-06.jpg'}

  it 'generates html detail file' do
    expect(File.exist?(html_file)).to be_truthy
  end

  it 'contains insert sample data' do
    expect(File.read(html_file).include?(sample_thumb)).to be(true)
  end

  before do
    zender = Dl::Zender::DetailZender.new(output_folder: './www/html')
    detail = Dl::Zender::DataClass::Detail.new
    detail.title = 'Hi hi day la title test'
    detail.meta = {
      author: 'Duc Linh',
      description: 'This is test of detail'
    }

    tags = ['haanhduclinh', 'Lanscape', 'Ha Noi']
    detail.post = {
      header: 'This is header.',
      thumbnail: sample_thumb,
      content: 'This is content.',
      author: 'Eric DUC LINH',
      author_url: 'http://haanhduclinh.com',
      public_date: Time.now.strftime("%m/%d/%Y %H-%M"),
      tags: tags
    }

    share = Dl::Zender::DataClass::Share.new
    share.categories = [
      { name: 'cat1', url: 'linh/123.html'},
      { name: 'cat2', url: 'linh/123.html'},
      { name: 'cat3', url: 'linh/123.html'},
    ]

    data = {
      data: detail,
      share: share,
    }
    zender.zending(data: data, url: '234')
    end
  end
end