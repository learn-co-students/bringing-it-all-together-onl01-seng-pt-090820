require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    @@all = []

    def initialize(id:nil,name:,breed:)
        @id = id
        @name = name
        @breed = breed
        @@all << self
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
        sql = <<-SQL
         DROP TABLE dogs
         SQL

        DB[:conn].execute(sql)
    end

    def self.all
        @@all
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
        doggie = Dog.new(name:name, breed:breed)
        doggie.save
        doggie
    end

    def self.new_from_db(row)
        doggie = self.new(id:row[0], name:row[1], breed:row[2])
        doggie
    end

    def self.find_by_id(num)	
        doggie = DB[:conn].execute("SELECT * FROM dogs WHERE id=?", num).first
        Dog.new(id: doggie[0], name: doggie[1], breed: doggie[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT id, name, breed
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        result = DB[:conn].execute(sql, name, breed)[0]
        if !result
            self.create(name: name, breed: breed)
        else
            self.new_from_db(result)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT id, name, breed
            FROM dogs
            WHERE name = ?
        SQL
        new_from_db(DB[:conn].execute(sql, name)[0])
      end
    
      def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed= ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
        self
      end

end