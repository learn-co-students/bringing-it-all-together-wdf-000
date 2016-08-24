require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_info, id=nil)
    self.name = dog_info[:name]
    self.breed = dog_info[:breed]
    @id = id
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
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
      VALUES(?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog_info)
    new_dog = Dog.new(dog_info)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
      new_dog = Dog.new({name: row[1], breed: row[2]}, row[0])
      new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * from dogs
      where id = ?
    SQL
    new_from_db(DB[:conn].execute(sql, id)[0])
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs
      where name = ?
    SQL
    dog = (DB[:conn].execute(sql, name)[0])
    if dog == nil
      dog = self.create({name: name})
    else
      dog = new_from_db(dog)
    end
    dog
  end

  def self.find_or_create_by(info_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", info_hash[:name], info_hash[:breed])
    if !dog.empty?
      new_dog = dog[0]
      dog = Dog.new({name: new_dog[1], breed: new_dog[2]}, new_dog[0])
    else
      dog = self.create(info_hash)
    end
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
  end


end
