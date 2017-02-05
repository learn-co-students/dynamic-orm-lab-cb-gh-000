require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"

    DB[:conn].execute(sql).collect do |column|
      column["name"]
    end.compact
  end

  def initialize(attributes={})
    attributes.each do |attr, value|
      self.send("#{attr}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |name|
      unless self.send("#{name}").nil?
        value = self.send("#{name}")
        value = "'#{value}'"
        # unless value.class == Fixnum
        # value
      end
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)

    sql = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    @id = DB[:conn].execute(sql)[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name='#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{hash.keys[0]}='#{hash.values[0]}'")
  end

end
