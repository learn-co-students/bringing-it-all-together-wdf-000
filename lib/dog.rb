require 'pry'
class Dog

  attr_accessor :name, :breed 
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT, 
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
      SQL
    DB[:conn].execute(sql, name, breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL

    dog_info = DB[:conn].execute(sql, num)[0]

    self.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0]) 
  end

  def self.find_or_create_by(name:, breed:)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if(dog_info.empty?)
      dog = self.create(name: name, breed: breed)
    else
      dog = self.new(name: dog_info[0][1], breed: dog_info[0][2], id: dog_info[0][0])
    end
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(name: name, breed: breed, id: id)
  end

  def self.find_by_name(name)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    self.new_from_db(dog_info[0])
  end

  def update
    dog_info = DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end