require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  class << self

    def table_name
      self.to_s.downcase.pluralize
    end

    def column_names
      sql = "PRAGMA table_info(#{table_name})"

      table_info = DB[:conn].execute(sql)
      column_names = []

      table_info.each do |column|
        column_names << column["name"]
      end

      column_names.compact
    end

    def find_by_name name
      find_by name: name
    end

    def find_by args
      key = args.keys[0]
      value = args.values[0]
      sql="SELECT * FROM #{table_name} WHERE #{key} = ?"
      DB[:conn].execute(sql,value)
    end
  end

  def initialize attributes = nil
    return self unless attributes
    attributes.each do |attribute,value|
      self.class.send(:attr_accessor, attribute)
      self.send("#{attribute}=" ,value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #binding.pry
    col_names.join(", ")
  end

  def col_names
    self.class.column_names.delete_if{|name| name == 'id'}
  end

  def values_for_insert
    values = []
    col_names.each do |column|
      values << "'#{self.send(column)}'"
    end
    values.join(", ")
  end

  def save
    sql="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end
