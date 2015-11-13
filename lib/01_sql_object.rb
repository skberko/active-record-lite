require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    raw_data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    columns = []
    # bc first el of raw_data is Array of Strings, each of which
    # is a name of a column:
    raw_data.first.each do |column|
      columns << column.to_sym
    end
    columns
  end

  def self.finalize!
    #getter
    columns.each do |column|
      define_method("#{column}") do
        # see setter method def to understand why we call attributes
        # as a method, NOT an instance variable @attributes here
        attributes[column]
      end
    end

    #setter
    columns.each do |column|
      define_method("#{column}=") do |value|
        # want to call the SQLObject#attributes method, NOT
        # the @attributes instance variable here;
        # if @attributes already initialized, the method will simply
        # return the initialized Hash object @attributes;
        # if @attributes not yet initialized, SQLObject#attributes
        # will initialize @attributes, return it, and allow column/value
        # pairs to be inserted into it
        attributes[column] = value
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    raw_data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    parse_all(raw_data)
  end

  def self.parse_all(results)
    ruby_object_results = []
    results.each do |result|
      ruby_object_results << self.new(result)
    end
    ruby_object_results
  end

  def self.find(id)
    raw_class_instance = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        "#{self.table_name}".id = ?
    SQL

    # "#{self.table_name}" above is optional, bc id can only
    # be from the one table we are examining;
    # '?' refers to the 'id' that we passed in as an argument
    # in execute above, which itself came from the argument of
    # self.find

    # need to turn raw SQL result (array of hashes) into an
    # instance of self:
    parse_all(raw_class_instance).first
  end

  def initialize(params = {})

    params.each do |attr_name, value|
      attr_symbol = attr_name.to_sym
      unless self.class.columns.include?(attr_symbol)
        raise "unknown attribute '#{attr_symbol}'"
      else
        # this calls the setter method created in SQLObject::finalize!
        # above and passes it to an instance of SQLObject along with
        # 'value', which the setter takes as an argument
        self.send("#{attr_name}=", value)
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
