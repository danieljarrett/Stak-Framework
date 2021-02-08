require 'erubis'

module Stak
	class Controller
		attr_reader :request, :response

		def initialize(env)
			@env = env
			@request = Rack::Request.new(env)
		end

		def resource
			klass = self.class
			resource = klass.to_resource
		end

		def vars
			instance_variables.reduce({}) do |acc, var|
				acc.update(var => instance_variable_get(var))
			end .update(params: params)
		end

		def params
			Hash[request.params.map{ |(key, value)| [key.to_sym, value] }]
		end

		def render(*args)
			@response = Rack::Response.new(result(*args), 200, { 'Content-Type' => 'text/html' })
		end

		def result(view, hsh = {})
			locals = hsh[:locals] || {}
			layout = hsh[:layout].nil? ? :default : hsh[:layout]
			insert = eruby(view, resource).result(locals.merge(vars))
			layout ? eruby(layout.to_s).result(insert: insert) : insert
		end

		def eruby(view, resource = :layouts)
			filepath = File.join('app', 'views', "#{resource}", "#{view}.html.erb")
			Erubis::Eruby.new(File.read(filepath))
		end

		def self.error
			-> (env) { [404, { 'Content-Type' => 'text/html' }, ['No Such Route']] }
		end

		def self.action(verb, route_params)
			-> (env) { self.new(env).append(route_params).dispatch(verb) }
		end

		def append(route_params)
			request.params.update(route_params)
			self
		end

		def dispatch(verb)
			self.send(verb.to_sym)
			response || render(verb)
		end

		def redirect(dest)
			@response = Rack::Response.new
			if dest.is_a? Hash
				verb = dest[:action]
				id = dest[:id] ? "/#{dest[:id]}" : ''
				response.redirect("/#{resource}#{id}/#{verb}")
			else
				response.redirect(dest)
			end
		end
	end
end