class Dog
  attr_accessor :name, :breed, :id
  def initialize(attributes)
    attributes.each{|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY ,
          name TEXT,
          breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
     DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
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

  def self.create(hash)
     dog = Dog.new(hash)
     dog.save
  end

  def self.find_by_id(id)
     sql = <<-SQL
         SELECT *
         FROM dogs
         WHERE id = ?
        SQL
      a = DB[:conn].execute(sql, id).first
      hash = {id: a[0], name: a[1], breed: a[2]}
      dog = Dog.new(hash)
      dog


  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      hash[:id] = dog[0][0]

      dog = Dog.new(hash)
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.new_from_db(row)
    hash = Hash.new
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    Dog.new(hash)

  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL

     dog = DB[:conn].execute(sql, name).first
     hash = Hash.new
     hash[:id] = dog[0]
     hash[:name] = dog[1]
     hash[:breed] = dog[2]
     self.find_or_create_by(hash)

  end




end
