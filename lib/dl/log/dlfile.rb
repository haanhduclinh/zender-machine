require 'fileutils'

module Dl
  module Log
    class Dlfile
      class << self
        def store_variant_to_file(var,path_to_save="dl_local_#{(Time.now).strftime('%Y%m%d')}")
          store_data = Marshal.dump(var)
          File.open(path_to_save,'w') { |file| file.write(store_data) }
        end

        def load_variant_from_file(file_path)
          store_data = File.read(file_path)
          obj = Marshal.load(store_data)
        end

        def create_directory_if_not_exist(path)
          dirname = File.dirname(path)
          unless File.directory?(path)
            FileUtils.mkdir_p(path)
          end
        end

        def table_status(start_time)
          # print "Loading: #{(Time.now - start_time).round}s", "\r"
          puts "================================================"
          puts "= Loading: #{(Time.now - start_time).round}s", "\n"
          puts "================================================"
        end
      end
    end
  end
end