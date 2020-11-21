class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,
        name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
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
        dog = self.new(name: name, breed: breed)
        dog.save
        dog      
    end

    def self.new_from_db(row)
      dog = self.new(id:row[0], name:row[1], breed:row[2])
      dog
    end

    def self.find_by_id(num)
       d = DB[:conn].execute("SELECT * 
        FROM dogs
        WHERE id = ?", num).first
        self.new(id:d[0], name:d[1], breed:d[2])
    end

    def self.find_or_create_by(name:, breed:)
       sql = <<-SQL
       SELECT id, name, breed
            FROM dogs
            WHERE name = ? AND breed = ?
       SQL
       r = DB[:conn].execute(sql, name, breed)[0]
       if !r
        self.create(name:name, breed:breed)
       else
        self.new_from_db(r)
       end
    end
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
         FROM dogs
         WHERE name = ?
        SQL
        new_from_db(DB[:conn].execute(sql, name)[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
    end
end