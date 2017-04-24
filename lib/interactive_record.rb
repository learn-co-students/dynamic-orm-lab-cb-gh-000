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
    table_info = DB[:conn].execute(sql)

    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  # Returns the column names that will be used to insert values into database
  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == "id" }
  end

  def self.find_by_name
  end

  # TODO - Student.table_name creates a downcased, plural table name based on the Class name
  # TODO - Student.find_by_name executes the SQL to find a row by name
  # TODO - Student initialize creates a new student with attributes
  # TODO - Student.column_names returns an array of SQL column names

  # TODO - Student has instance methods to insert data into db #values_for_insert formats the column names to be used in a SQL statement
  # TODO - Student has instance methods to insert data into db #table_name_for_insert return the table name when called on an instance of Student
  # TODO - Student has instance methods to insert data into db #save saves the student to the db
  # TODO - Student has instance methods to insert data into db #save sets the student's id # Student has instance methods to insert data into db #col_names_for_insert return the column names when called on an instance of Student

  # TODO - Student.find_by accounts for when an attribute value is an integer
  # TODO - Student.find_by executes the SQL to find a row by the attribute passed into the method
end