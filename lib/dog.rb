class Dog

	attr_accessor :name, :breed
	attr_reader :id	

	def initialize(id: nil, name:, breed:)
		@id = id
		@name = name
		@breed = breed
	end

	def self.create_table
		sql =<<-SQL 
		CREATE TABLE IF NOT EXISTS dogs(
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
				INSERT INTO dogs (name, breed)
				VALUES (?, ?)
			SQL

		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
		end
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def self.create(name:, breed:)
		new_dog = self.new(name: name, breed: breed)
		new_dog.save
		new_dog
	end

	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = ?"
		row = DB[:conn].execute(sql, id)[0]
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
			new_row = row [0]
			row = Dog.new(name: new_row[1], breed: new_row[2], id: new_row[0])
		else
			row = self.create(name: name, breed: breed)
		end
		row
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM dogs WHERE name = ?"
		row = found_name = DB[:conn].execute(sql, name)[0]
		self.new_from_db(row)
	end

end

