require 'pry'

class Dog

  attr_accessor :name, :breed    #we can update your name and breed but only read your id because
  attr_reader :id               #it is assigned.


  def initialize(name:, breed:, id: nil)   #use keys as the attributes of an object when created
    @name = name                          #object id is defaluted to nil.
    @breed = breed
    @id = id

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
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  end



  def update
    sql = "UPDATE dogs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end


  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  #we use metaprogramming to just make a cleanse attribute so that
  #when other programmers look at our code and use the code it prevents them
  #from messing up the attribute order.


  def self.find_by_id(x)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, x)[0]
    self.new_from_db(row)

  end

  def self.new_from_db(row)
    name = row[1]
    breed = row[2]
    id = row[0]
    new_dog = self.new(name: name, breed: breed, id: id)
    new_dog
  end


  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !row.empty?
      new_row = row[0]
      row = Dog.new(name: new_row[1], breed: new_row[2], id: new_row[0])
    else
      row = self.create(name: name, breed: breed)
    end
      row
  end


  #The spec asks you to check you to check if the data instance already exists. We check
  # by name and breed because two dogs can have the same name but different breed. Rememeber
  #in sql language we USE AND TO INCLUDE TWO DIFFERENT CONDITIONS WITH "WHERE". if we actually get
  #an instance we create a new ruby object with that instance. else we create a new instance with
  # the name and breed attribute for the given arguments. remember this is meta programming
  #we have to include the key with the values
  #row is NOT! empty. it has another array as element 0.


  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = found_name = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end





  end
