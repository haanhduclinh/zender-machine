source 'https://rubygems.org'
ruby '2.3.0'
gem 'googleauth'
gem 'google-api-client'
gem 'redis'
gem 'sinatra'
gem 'config', '1.4.0'
gem 'highscore'
gem 'stemmer', '~> 1.0', '>= 1.0.1'
gem 'stanford-core-nlp'
gem 'engtagger', github: 'haanhduclinh/engtagger'
gem 'rubypress'
gem 'mysql2', '~> 0.4.5'
gem 'stringex', '~> 2.7', '>= 2.7.1'
gem 'activesupport'
gem 'whenever', :require => false

gem 'le'
gem 'ConnectSDK', git: 'git@github.com:haanhduclinh/gettyimages-api_ruby.git'
gem 'whatlanguage', '~> 1.0', '>= 1.0.6'
gem 'bing-search'
gem 'auto_html'
gem 'eventmachine'
gem 'em-websocket'
gem 'em-http-request'
gem 'nokogiri'

gem 'ruby-debug-ide'
gem 'debase'
gem 'faker'
gem 'linkedin', git: 'git@github.com:haanhduclinh/linkedin.git'

group :test do
  gem 'shoulda'
  %w[rspec rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
  end
end

group :development do
  gem 'rubocop', '~> 0.47.1', require: false
  gem 'pry'
  gem 'dotenv-rails'
end