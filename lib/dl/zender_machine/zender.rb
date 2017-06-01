require 'erb'

module Dl
  module ZenderMachine
    class Zender
      def initialize(output_folder:)
        @output_folder = output_folder
      end

      def zending(erb_file:, data: {}, url:)
        html_file = "#{@output_folder}/#{url}.html"
        erb_str = File.read(erb_file)
        # load instance variant
        create_instance_variant(data)
        result = ERB.new(erb_str).result(binding)

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
