class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
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
        sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)        
        dog.save
        dog
    end

    def self.find_or_create_by(name:, breed:)
        # can we find the dog?
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            LIMIT 1
        SQL
        dog_data = DB[:conn].execute(sql, name, breed)

        # if we find it
        if !dog_data.empty?
        # return the instance
            dog = self.new(name: name, breed: breed, id: dog_data[0][0])
        # if not
        else
        # create it
            dog = self.create(name: name, breed: breed)
        end
        dog

    end

    def self.new_from_db(row)
        attributes = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
        }
        self.new(attributes)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
      end

     

      def update
        sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

end