class Dog

  attr_accessor :name, :id, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    data = DB[:conn].execute(sql, name, breed)
    if data.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog = Dog.new_from_db(data[0])
    end
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
