require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
 
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql) 
    
    column_names = []

    table_info.each do |row|
    column_names << row["name"]
    end
    column_names.compact
  end
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=",value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col|col == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |value_key|
      values << "'#{send(value_key)}'" unless send(value_key).nil?    
    end
    values.join(", ")
  end


  # def save
  #   sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  #   DB[:conn].execute(sql)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  # end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{table_name}
    WHERE name = ? LIMIT 1
    SQL
    # binding.pry
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    key =  hash.keys.first
    value = hash[key]
    # hash = {name: 'Susan', grade: '12'}
    end_value = value == value.to_s ? "'#{value}'" : value.to_i

    sql = "SELECT * FROM #{table_name} WHERE #{key.to_s} = #{end_value}"
    # binding.pry
    DB[:conn].execute(sql)
  end

end
