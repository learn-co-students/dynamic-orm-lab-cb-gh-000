require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash
    sql = <<-SQL
    PRAGMA table_info("#{table_name}")
    SQL
    table_info = DB[:conn].execute(sql)
    columns_names = []
    table_info.each { |col|
      columns_names << col["name"]
    }
    columns_names.compact
  end

  def initialize(attributes={})
    attributes.each { |k,v|
      self.send("#{k}=",v)
    }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{|x| x=="id"}.compact.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each { |name|
      values << "'#{send(name)}'" unless send(name).nil?
    }
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name=?
    SQL
    DB[:conn].execute(sql,name)
  end

  def self.find_by(x)
    col_name = x.keys[0].to_s
    col_value = x.values[0]
    sql = <<-SQL
    SELECT * FROM #{table_name} WHERE #{col_name}=?
    SQL
    DB[:conn].execute(sql,col_value)
  end

end


# learn --fail-fast
