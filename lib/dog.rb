class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each { |key, value| self.send("#{key}=", value) }
    @id ||= nil
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    persisted? ? update : insert
  end

  def self.create(attributes)
    self.new(attributes).tap(&:save)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id=?"
    row = DB[:conn].execute(sql, id).flatten
    new_from_db(row)
  end

  def self.find_or_create_by(attributes)
    !!find(attributes) ? find(attributes) : self.create(attributes)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name=? LIMIT 1"
    new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find(attributes)
    sql = "SELECT * FROM dogs WHERE name=? AND breed=?"
    row = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).flatten
    row.empty? ? nil : new_from_db(row)
  end

  def persisted?
    !!self.id
  end

  def insert
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end
end
