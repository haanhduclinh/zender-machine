module Apps
  class Config
    def initialize(args, &block)
      block.call if block_given?
      args.each do |key, value|
        self.instance_variable_set("@#{key}") = value
      end
    end
  end
end

Apps::Config.new do |c|
  c.hostname = 'localhost'
  c.username = 'dl'
  c.password = '123'
  c.port = '3307'
end
