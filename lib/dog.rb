class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
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
      arrays = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", @id)
      pokemon_data = arrays[0]
      Dog.new_from_db(pokemon_data)
    end
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end 
  
  def self.new_from_db(dog_array)
    hash = {} 
    hash[:id] = dog_array[0]
    hash[:name] = dog_array[1]
    hash[:breed] = dog_array[2]
    Dog.create(hash)
  end
  
  def self.find_by_id(id)
    arrays = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
    dog_array = arrays[0]
    Dog.new_from_db(dog_array)
  end
  
  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    results = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !results.empty?
      dog_array = results[0]
      dog = Dog.new_from_db(dog_array) 
    else
      dog = self.create(hash)
    end
    dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |dog_row|
      self.new_from_db(dog_row)
    end.first
  end
    
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end