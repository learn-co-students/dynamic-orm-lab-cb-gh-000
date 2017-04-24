require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(attributes={})
    self.attributes = attributes
  end

  def attributes=(attributes)
  end

  # Saves instance attributes to database
  def save
  end

  # Creates attr_accessors for each column name from database
  def attr_accessor
  end

  # Returns an array of SQL column names
  def self.column_names
    sql = 'PRAGMA table_info(<table name>)'
  end

  def self.find_by_name
  end
end