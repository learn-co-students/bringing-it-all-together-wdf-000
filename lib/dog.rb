require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attr, id = nil)
    @id = id
    attr.each {|key, value| self.send(("#{key}="), value)} 
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

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

  def insert 
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end

  def self.create(attr)
    dog = self.new(attr) 
    dog.save
  end

  def self.new_from_db(row)
    dog = new(name: row[1], breed: row[2], id: row[0])
    dog 
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    row = DB[:conn].execute(sql, name, breed).flatten
    if !row.empty?
      song = self.new_from_db(row)
    else 
      attr = {name: name, breed: breed}
      song = self.create(attr)
    end
    song
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).flatten
    new_from_db(row)
  end

end 
