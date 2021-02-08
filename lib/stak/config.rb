module Stak
	class Router
		def root(action = nil, &block)
			get('/', action, &block)
		end

		%w(delete get head options patch post put).each do |verb|
			define_method(verb) do |path, action = nil, &block|
				@routes[verb.to_sym] << route(path, action, &block)
			end
		end

		def route(path, action, &block)
			{
				path: Regexp.new("^#{path.gsub(/:\w+/) { |param| '([^/?#]+)' }}$"),
				params: path.scan(/:\w+/).map { |param| param.gsub(':', '') },
				target: action || block
			}
		end

		def resources(resource, opt = {})
			maps(resource).each do |map|
				map[:rests].each do |verb, rest|
					@routes[verb] << { path: map[:root] + rest + /$/ }
				end
			end

			@routes[:get] << { path: /(#{resource})\/(a^)?([A-Za-z0-9_]+)/ } if opt[:access]
		end

		def maps(resource)
			[
				{
					root: /(#{resource})\/([0-9]+\/)?/,
					rests: {
						get: /(show|edit)/,
						put: /(update)/,
						patch: /(update)/,
						delete: /(delete)/
					}
				},
				{
					root: /(#{resource})\/(a^)?/,
					rests: {
						get: /(index|new)/,
						post: /(create)/
					}
				}
			]
		end
	end
end
