require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if self.id
      sql = 
      <<-SQL
      update students 
      set name = ?, grade = ?
      where id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = 
      <<-SQL
      insert into students (name, grade)
      values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
    end
  end

  def update
    sql = 
    <<-SQL
    insert into students (name, grade)
    values (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    sql = 
    <<-SQL
    insert into students (name, grade)
    values (?, ?)
    SQL
    DB[:conn].execute(sql, student.name, student.grade)
    @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
  end

  def self.create_table
    sql = 
    <<-SQL
    create table if not exists students (
      id INTEGER PRIMARY KEY,
      name text,
      grade text
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =
    <<-SQL
    drop table if exists students
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = 
    <<-SQL
    select * from students where name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

end
