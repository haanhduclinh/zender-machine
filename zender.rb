require 'erb'
require 'pry'

module Apps
  module Zender
    class Zen
      TEMPLATE = {
        PAGE_DETAIL: './views/page.html.erb',
        FOOTER: './views/footer.html.erb',
      }.freeze

      def initialize(output_folder:)
        @output_folder = output_folder
      end

      def zending(templates:, data: {}, url:)
        html_file = "#{@output_folder}/#{url}.html"

        html = templates.map do |template|
          erb_file = TEMPLATE[template.to_sym]
          File.read(erb_file)
        end
        # load instance variant
        create_instance_variant(data)

        a = File.read('./views/footer.html.erb')
        eval('footer=a;')
        result = ERB.new(html.join).result(binding)

        File.open(html_file, 'w') do |f|
          f.write(result)
        end
      end

      def create_instance_variant(data)
        data.each do |key, value|
          self.instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end

zender = Apps::Zender::Zen.new(output_folder: './html')
data = {
  name: 'duc linh',
  title: 'this is test title'
}
zender.zending(templates: ['PAGE_DETAIL'], data: data, url: 'detail-1')
