require 'pry'
require_relative "../config/environment.rb"

class Dog
	attr_accessor :name, :breed, :id

	def id
		@id
	end

	def initialize(name:,breed:,id:nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs ( id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS dogs")
	end

	def save
		if @id
			update
		else
			DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (? , ? );",@name,@breed)
			@id = DB[:conn].execute("SELECT MAX(id) FROM dogs").first[0]
		end
		self
	end

	def update
		DB[:conn].execute("UPDATE dogs SET name == ?, breed == ? WHERE id == ?;",@name,@breed,@id)
	end

	def self.create(name: ,breed:)
		Dog.new(name: name,breed: breed).save
	end

	def self.find_by_id(num)
		row = DB[:conn].execute("SELECT * FROM dogs WHERE id == ?;",num).first
		Dog.new(name: row[1], breed: row[2], id:row[0])
	end

	def self.find_by_name(name)
		row = DB[:conn].execute("SELECT * FROM dogs WHERE name == ?;",name).first
		Dog.new(name: row[1], breed: row[2], id:row[0])
	end

	def self.find_or_create_by(name:,breed:)
		row = DB[:conn].execute("SELECT * FROM dogs WHERE name  == ? AND breed == ?;", name, breed).first
		row ? Dog.find_by_id(row[0]) : Dog.create(name:name,breed:breed)
	end

	def self.new_from_db(row)
		Dog.new(name:row[1],breed:row[2],id:row[0])
	end
end
