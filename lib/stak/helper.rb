class Object
	def self.const_missing(c)
		require c.to_s.to_snakecase
		Object.const_get(c)
	end
end

class String
	def to_camelcase
		self.
			split('_').
			collect(&:capitalize).
			join
	end

	def to_snakecase
		self.
			gsub(/::/, '/').
			gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
			gsub(/([a-z\d])([A-Z])/,'\1_\2').
			tr('-', '_').
			downcase
	end

	def to_klass
		Object.const_get(self.to_camelcase + 'Controller')
	end
end

class Class
	def to_resource
		self.to_s.match(/(?<!::)Controller$/) ? self.to_s.gsub(/Controller$/, '').to_snakecase : ''
	end
end

class Hash
	def permit(*args)
		self.select { |key, value| [*args].include? key.to_sym }
	end

	def draw(hash)
		s = self.shift
		self.update(hash).update(s[0] => s[1])
	end
end

class Regexp
  def +(r)
    Regexp.new(source + r.source)
  end
end