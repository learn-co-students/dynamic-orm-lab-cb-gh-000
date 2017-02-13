require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    columns_names = []
    DB[:conn].execute(sql).each do |column_hash|
      columns_names << column_hash["name"]
    end
    columns_names
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
    self.class.column_names.select do |column_name|
      column_name != "id"
    end.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
      values << "'" + self.send("#{column_name}").to_s + "'" unless column_name == "id"
    end
    values.join(", ")
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO #{self.table_name_for_insert}
        (#{col_names_for_insert}) VALUES (#{values_for_insert})
      SQL
      DB[:conn].execute(sql)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(search_hash)
    cols_for_select = []
    values_for_select = []
    search_hash.each do |key, value|
      cols_for_select << "#{key.to_s} = ?"
      values_for_select << value.to_s
    end
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{cols_for_select.join(" AND ")}
    SQL
    DB[:conn].execute(sql, *values_for_select)
  end
end