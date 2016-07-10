class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  def self.create_table
    sql = <<-SQL
	CREATE TABLE
	IF NOT EXISTS dogs
	  (id INTEGER PRIMARY KEY,
	  name TEXT,
	  breed TEXT);
      SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end
  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end
  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
  end
  def self.find_by_id(id)
    sql = <<-SQL
	SELECT * FROM dogs
	WHERE id = ?;
      SQL
    self.new_from_db(DB[:conn].execute(sql,id)[0])
  end
  def self.find_or_create_by(hash)
    sql = <<-SQL
	SELECT * FROM dogs
	WHERE name = ?
	AND breed = ?;
      SQL
    result = DB[:conn].execute(sql,hash[:name],hash[:breed])[0]
    result ? self.new_from_db(result) : self.create(hash)
  end
  def self.find_by_name(name)
    sql = <<-SQL
	SELECT * FROM dogs
	WHERE name = ?;
      SQL
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end
  def save
    sql = <<-SQL
	INSERT INTO dogs (name, breed)
	VALUES (?, ?);
      SQL
    DB[:conn].execute(sql, @name, @breed)
    self.id = DB[:conn].execute("SELECT id FROM dogs WHERE id = last_insert_rowid();")[0][0]
    self
  end 
  def update
    sql = <<-SQL
	UPDATE dogs
	SET name = ?, breed = ?
	WHERE id = ?;
      SQL
    DB[:conn].execute(sql,@name,@breed,@id)
  end
end
