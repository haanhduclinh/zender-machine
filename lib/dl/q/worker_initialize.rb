module Dl
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def worker_initialize(method_name, options = {})
      dl_methods = Array(options[:only]).compact
      return if dl_methods.empty?
      dl_methods.each do |m|
        alias_method "#{m}_old", m
        class_eval <<-RUBY,__FILE__,__LINE__ + 1
          def #{m}
            #{method_name}
            #{m}_old
          end
        RUBY
      end
    end
  end
end