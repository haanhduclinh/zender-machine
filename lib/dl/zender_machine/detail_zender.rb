require 'erb'
require_relative './data_class/detail.rb'
require_relative './data_class/share.rb'

module Dl
  module Zender
    class DetailZender
      HOME_PAGE_FOLDER = './template/dl/detail'.freeze
      HOME_PAGE_SHARED = './template/dl/shared'.freeze

      def initialize(output_folder: )
        @output_folder = output_folder
      end

      def zending(data: {}, url: )
        html_file = "#{@output_folder}/#{url}.html"
        html = File.read("#{HOME_PAGE_FOLDER}/detail.html.erb")
        # load instance variant

        create_instance_variant_data(data)

        create_instance_variant_template(list_partials_shared + list_partials)
        result = ERB.new(html).result(binding)

        File.open(html_file, 'w') do |f|
          f.write(result)
        end
      end

      def list_partials
        Dir["#{HOME_PAGE_FOLDER}/*"].select { |filename| filename.split('/').last[0] == '_' }
      end

      def list_partials_shared
        Dir["#{HOME_PAGE_SHARED}/*"].select { |filename| filename.split('/').last[0] == '_' }
      end

      def create_instance_variant_template(partials_path)
        partials_path.each do |partial_path|
          file_name = File.basename(partial_path, '.html.erb')
          file_data = ERB.new(File.new(partial_path).read).result(binding)
          self.instance_variable_set("@#{file_name}", file_data)
        end
      end

      def create_instance_variant_data(data)
        data.each do |key, value|
          self.instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
