require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(dog_hash)
    dog_hash.each{ |key,value|  self.send("#{key}=",value)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES(?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      # binding.pry
    end
    self
  end

  def self.create(dog_hash)
    self.new(dog_hash).tap{|dog| dog.save }
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    info = DB[:conn].execute(sql, id).first
    self.new(name: info[1], breed: info[2], id: info[0]).tap{|dog| dog}
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    info = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).first

    if info == nil
      self.create(dog_hash)
    else
      dog_hash[:id] = info[0]
      self.new(dog_hash).tap{|dog| dog }
    end
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0]).tap{|dog| dog}
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    info = DB[:conn].execute(sql, name).first
    self.new(name:info[1], breed:info[2], id:info[0]).tap{|dog| dog}
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
