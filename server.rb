#!/usr/bin/env ruby

require 'goliath'
require 'em-synchrony/em-http'

class Server < Goliath::API
  use Goliath::Rack::Params

  def response(env)
    ret = EM::HttpRequest.new(env.params['url']).get
    [200, {status: ret.response_header.status.to_s}, ret.response]
  end
end