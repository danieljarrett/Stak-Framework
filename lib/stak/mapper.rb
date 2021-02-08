require 'sqlite3'

module Stak
	class Mapper
		attr_accessor :id

		@@db = SQLite3::Database.new(File.join('db', 'app.db'))

		@@table = ''
		@@mappings = { id: :id }

		def initialize(hsh = {})
			@@mappings.values.each do |attr|
				instance_variable_set("@#{attr}", hsh[attr.to_s])
			end
			@created_at = Time.now
		end

		def save
			@@db.execute(
				"
					INSERT INTO #{@@table} (#{columns.join(',')})
					VALUES (#{columns.map { |col| '?' }.join(',')})
				",
				values
			)
		end

		def update(hsh)
			@@mappings.values.each do |attr|
				instance_variable_set("@#{attr}", hsh[attr.to_s]) if hsh[attr.to_s]
			end

			@@db.execute(
				"
					UPDATE #{@@table}
					SET #{columns.map { |col| "#{col} = ?" }.join(',')}
					WHERE id = ?
				",
				values(true)
			)
		end

		def columns(with_id = false)
			if with_id
				@@mappings.keys
			else
				@@mappings.keys.reject{ |col| col == :id }
			end
		end

		def values(with_id = false)
			if with_id
				@@mappings.values.map { |method| self.send(method) }
			else
				@@mappings.values.reject{ |attr| attr == :id }.map { |method| self.send(method) }
			end
		end

		def self.find(id)
			row = @@db.execute(
				"
					SELECT #{@@mappings.keys.join(',')}
					FROM #{@@table}
					WHERE id = #{id}
				"
			).first

			self.instantiate(row)
		end

		def self.all
			data = @@db.execute(
				"
					SELECT #{@@mappings.keys.join(',')}
					FROM #{@@table}
				"
			)

			data.map do |row|
				self.instantiate(row)
			end
		end

		def self.first
			row = @@db.execute(
				"
					SELECT #{@@mappings.keys.join(',')}
					FROM #{@@table}
					ORDER BY id
					LIMIT 1
				"
			).flatten

			self.instantiate(row)
		end

		def self.last
			row = @@db.execute(
				"
					SELECT #{@@mappings.keys.join(',')}
					FROM #{@@table}
					ORDER BY id DESC
					LIMIT 1
				"
			).flatten

			self.instantiate(row)
		end

		def self.instantiate(row)
			model = self.new

			@@mappings.each_value.with_index do |attr, index|
				model.send("#{attr}=", row[index])
			end

			model
		end

		def destroy
			@@db.execute(
				"
					DELETE FROM #{@@table}
					WHERE id = #{self.id}
				"
			)
		end
	end
end
