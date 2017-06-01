require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/blogger_v3'
require './lib/content_creater'
require 'fileutils'
require 'pry'

module Dl
  module Blogger
    class Adapter

      def initialize(client_json_file, user_email, token_store_path, blog_url, avata_url)
        oob_url = 'http://localhost:4567/oauth2callback'.freeze
        scope = 'https://www.googleapis.com/auth/blogger'
        client_id = Google::Auth::ClientId.from_file(client_json_file)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: token_store_path)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
        user_id = user_email
        @credentials = authorizer.get_credentials(user_id)

        if @credentials.nil?
          url = authorizer.get_authorization_url(base_url: oob_url )
          puts "Open #{url} in your browser and enter the resulting code:"
          code = gets
          @credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id,
            code: code,
            base_url: oob_url
          )

          unless File.exist?(token_store_path)
            FileUtils.mv('tokens.yml', token_store_path)
          end

          @blog_url = blog_url
          @avata_url = avata_url
        end
      end

      def post(blog_id:, display_name:, post_hash:)
        blog = Google::Apis::BloggerV3::BloggerService.new
        blog.authorization = @credentials

        post_object = Google::Apis::BloggerV3::Post.new
        post_object.author = Google::Apis::BloggerV3::Post::Author.new(
          display_name: display_name,
          id: '1',
          image: @avata_url,
          url: @blog_url
        )

        picture_arr = create_picture_arr(post_hash[:picture])

        picture_html = create_img_html(
          src: post_hash[:picture],
          alt: post_hash[:labels].join(','),
          title: post_hash[:title]
        )

        while post_hash[:labels].join.length > 180
          post_hash[:labels].pop
        end

        post_content = format("%s%s", picture_html, post_hash[:content])

        post_object.blog = Google::Apis::BloggerV3::Post::Blog.new()
        post_object.content = post_content
        post_object.title = post_hash[:title]
        post_object.labels = post_hash[:labels]
        post_object.images = picture_arr if post_hash[:picture]

        blog.insert_post(blog_id,post_object) do |result, err|
          if result
            result.url
          else
            "Error:#{err} at #{Time.now}"
          end
        end
      end

      def create_picture_arr(*args)
        args.map do |picture_url|
          Google::Apis::BloggerV3::Post::Image.new.url = picture_url
        end
      end

      def create_img_html(src:, alt:, title:)
        format("<img src='%s' alt='%s' title='%s'>", src, alt, title)
      end
    end
  end
end
