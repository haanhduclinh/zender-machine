require 'open-uri'
require 'stringex'
require 'active_support/inflector'
require 'pry'

module Dl
  module Q
    module_function

    def to_url(str)
      url = str.to_url
      if url.size > 80
        url.slice(0, 80)
      else
        url
      end
    end

    def remove_lines(text, i)
      text.split("\n")[i..-1].join("\n")
    end

    def remote_first(text)
      text.lines.to_a[2..-1].join
    end

    def get_file_from_url(url, path_to_save)
      File.open(path_to_save, 'wb') do |fo|
        fo.write open(url).read
      end
      path_to_save
    end

    def list_all_file(folder_name)
      Dir[ File.join(folder_name, '**', '*') ].reject { |p| File.directory? p }
    end

    def load_lib(lib_path)
      list_all_file(lib_path).each {|file| require file}
    end

    def ordinal(number)
      abs_number = number.to_i.abs

      if (11..13).include?(abs_number % 100)
        "th"
      else
        case abs_number % 10
          when 1; "st"
          when 2; "nd"
          when 3; "rd"
          else    "th"
        end
      end
    end

    def ordinalize(number)
      "#{number}#{ordinal(number)}"
    end

    def remove_underline(text)
      text.humanize.titleize
    end

    def format_title(text)
      text.titleize
    end

    def upacase_first(text)
      text.upcase_first
    end

    def en_uppercase?(letter)
      case letter
      when /[[:upper:]]/ then true
      when /[[:lower:]]/ then nil
      else
        nil
      end
    end

    def get_file_extend(image_file_path)
      accept_format = ['png', 'jpg']
      format_image_path = image_file_path.downcase
      accept_format.each { |type| return type if format_image_path.include? type }
    end
  end
end