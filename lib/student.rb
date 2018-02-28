require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  #Makes attr_accessor for each col
  self.column_names.each do |col_name|
    #Need to change from str to sym
    attr_accessor col_name.to_sym
  end
end
