class Dog
    attr_accessor :id, :name, :breed
  

    def initialize(attributes)
      attributes.each {|key, value| self.send(("#{key}="), value)}
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
        if self.id
        self.update
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
        dog
    end

    
    def self.new_from_db(row)
        attributes = {
        id: row[0],
        name: row[1],
        breed: row[2]
        }
        self.new(attributes)
    end
    

    def self.all
        sql = "SELECT * FROM dogs"
        DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
        end
    end


    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
        end.first
    end
      
      
    def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL
    
        DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
        end.first
    end
    

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
        if dog
        new_from_db(dog)
        else
        create(name: name, breed: breed)
        end
    end
    
  
    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
        
end
    
  