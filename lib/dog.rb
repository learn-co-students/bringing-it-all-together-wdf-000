class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.all
    all = DB[:conn].execute("SELECT * FROM dogs")
    all.map { |row| self.new_from_db(row) }
  end

  def self.create(*args)
    self.new(*args).save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    self.all.detect { |dog| dog.id == id }
  end

  def self.find_or_create_by(hash)
    found_dog = self.all.detect { |dog| dog.name == hash[:name] && dog.breed == hash[:breed] }
    found_dog ? found_dog : self.create(hash)
  end

  def self.find_by_name(name)
    self.all.detect { |dog| dog.name == name }
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
end