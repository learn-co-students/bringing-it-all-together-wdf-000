require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(params)
    params.each{|key, value| self.send("#{key}=", value)}
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)
    self.id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", name, breed)[0][0]
    self
  end

  def self.create(params)
    new_dog = new(params).save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    new_dog = new_from_db(row)
  end

  def self.new_from_db(row)
    attr_hash = {:id => row[0], :name => row[1], :breed => row[2]}
    new(attr_hash)
  end

  def self.find_or_create_by(attr_hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? & breed = ?
    SQL

    poss_dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])

    if poss_dog.empty?
      create(attr_hash)
    else
      find_by_id(poss_dog[0])
    end

  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, id)
  end

end
