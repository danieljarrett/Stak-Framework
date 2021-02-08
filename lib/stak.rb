require 'stak/version'
require 'stak/helper'
require 'stak/router'
require 'stak/config'
require 'stak/controller'
require 'stak/mapper'

module Stak
	class Application
    attr_reader :router

    def initialize
      @router = Stak::Router.new
    end

    def call(env)
      mapp(env).call(env)
    end

    def mapp(env)
      router.match(env['PATH_INFO'], env['REQUEST_METHOD'].downcase.to_sym, env)
    end
  end
end
