require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash, id = nil)
    @id = id
    hash.each {|key, value| self.send(("#{key}="), value)} 
  end 


  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )"
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

end 
