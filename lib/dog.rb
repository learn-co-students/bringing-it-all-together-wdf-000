class Dog
	# refer to the applications connection to the database
	# DB[:conn]

	attr_accessor :name, :breed
	attr_reader :id

	def initialize(id: nil, name:, breed:)
		@id = id
		@name = name
		@breed = breed
	end

	def self.create_table
		sql = <<-SQL
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
			sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
			self
		end
	end

	def self.create(dog_attributes)
		dog = self.new(dog_attributes)
		dog.save
	end

	def self.find_by_id(id_num)
		sql = "SELECT * FROM dogs WHERE id = ?"
		dog_from_db = DB[:conn].execute(sql, id_num)[0]
		self.new(id:dog_from_db[0], name:dog_from_db[1], breed:dog_from_db[2])
	end

	def self.find_or_create_by(dog_attributes)
		sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
		dog_from_db_data = DB[:conn].execute(sql, dog_attributes[:name], dog_attributes[:breed])
		if !dog_from_db_data.empty?
			dog = dog_from_db_data[0]
			dog_from_db = self.new(id: dog[0], name: dog[1], breed: dog[2])
		else
			new_dog = self.create(dog_attributes)
		end
	end

	def self.new_from_db(row)
		new_dog = self.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM dogs WHERE name = ?"
		dog_from_db_by_name_data = DB[:conn].execute(sql, name)
		dog_from_db = dog_from_db_by_name_data[0]
		self.new(id:dog_from_db[0], name:dog_from_db[1], breed:dog_from_db[2])
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

end