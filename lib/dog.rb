require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      name TEXT,
      breed TEXT
    )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL

      DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
            # binding.pry
  end

  def self.create(hash)
    self.new(hash).save
  end

  def self.find_by_id(x)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL

      array = DB[:conn].execute(sql, x)

      array_hash = {name: array.flatten[1], breed: array.flatten[2]}
      new_dog = self.new(array_hash)
      new_dog.id = array.flatten[0]

      new_dog
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    # ********
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog_data = dog[0]
      # dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end

    dog

  end

  def self.new_from_db(array)
    new_from_db = self.new(name: array[1], breed: array[2])
    new_from_db.id = array[0]
    new_from_db
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
      end.first
      # binding.pry
      # ************
  end

  def update
    sql = <<-SQL
    UPDATE DOGS
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
