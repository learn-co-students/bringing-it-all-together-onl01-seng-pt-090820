class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
    self
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
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end

    def save
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
      dog
    end
   
    def self.new_from_db(row)
      dog = self.new(id: row[0], name: row[1], breed: row[2])
      dog
    end

    def self.find_by_id(id)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
      new_dog = self.new_from_db(row[0])
      new_dog
    end
  

    def self.find_or_create_by(hash)
      
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
      if !dog.empty?
        id = DB[:conn].execute("SELECT id FROM dogs")[0][0]
        #binding.pry
        dog = self.new(id: id, name: hash[:name], breed: hash[:breed])
        dog
      else
        dog = self.create(name: hash[:name], breed: hash[:breed])
      end
        dog

    end


    def self.find_by_name(name)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
      new_dog = self.new_from_db(dog[0])
      new_dog
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end