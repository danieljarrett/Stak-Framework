module Stak
	class Router
		def initialize
			@routes = Hash.new { |hash, key| hash[key] = [] }
		end

		def config(&block)
			instance_eval(&block)
		end

		def match(url, verb, env)
			@routes[verb].each do |route|
				if route[:path].match(url)
					return case route[:target]
					when Proc then block($~.captures, route, env)
					when String	then action($~.captures, route)
					when NilClass then default($~.captures)
					end
				end
			end
			return Stak::Controller.error
		end

		def block(captures, route, env)
			route_params = captures.each_with_index.reduce({}) do |acc, (value, index)|
				acc.update(route[:params][index] => value)
			end

			Stak::Controller.send(:define_method, :_t, route[:target])
			-> (env) { Stak::Controller.new(env).append(route_params)._t }
		end

		def action(captures, route)
			route_params = captures.each_with_index.reduce({}) do |acc, (value, index)|
				acc.update(route[:params][index] => value)
			end

			retrieve(route[:target], route_params)
		end

		def default(captures)
			route_params = captures[1] ? { 'id' => captures[1][0..-2] } : {}

			retrieve("#{captures[0]}##{captures[2]}", route_params)
		end

		def retrieve(action, route_params)
			if action =~ /^([^#]+)#([^#]+)$/
				resource = $1.to_camelcase
				klass = resource.to_klass
				return klass.action($2, route_params)
			end
		end
	end
end