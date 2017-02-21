require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def self.table_name
		self.to_s.downcase.pluralize
	end

	def self.column_names
		columns = []
		DB[:conn].execute("PRAGMA table_info(#{self.table_name})").each do |column|
			columns << column['name']
		end
		columns
	end

	def initialize(options = {})
		options.each do |key, value|
			self.send("#{key}=", value)
		end
	end

	def table_name_for_insert
		self.class.table_name
	end

	def col_names_for_insert
		self.class.column_names.select{ |name| name != "id" }.join(", ")
	end

	def values_for_insert
		values = []
		self.class.column_names.each do |name|
			values << "'" + self.send("#{name}").to_s + "'" unless name.eql? 'id'
		end
		values.join(", ")
	end

	def save
		if !self.id
			DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
			self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
		end
	end

	def self.find_by_name(name)
		DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name=?", name)
	end

	def self.find_by(hash)
		DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hash.keys.first.to_s} = ?", hash.values.first)
	end

end

