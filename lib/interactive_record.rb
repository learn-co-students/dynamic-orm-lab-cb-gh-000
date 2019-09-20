require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info(#{table_name})"
    data = DB[:conn].execute(sql)
    column_names = []
    data.each {|hash| column_names << hash["name"]}
    column_names.compact
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    self
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|value| self.send("#{value}") == nil}.join(", ")
  end

  def values_for_insert
    values = []
    attributes = self.class.column_names.delete_if{|value| self.send("#{value}") == nil}
    attributes.each {|att| values << "'" + self.send("#{att}").to_s + "'"}
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def class.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"

    self.new(DB[:conn].execute(sql, name)[0])
  end

end
