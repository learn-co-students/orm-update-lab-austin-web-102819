require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade
  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade TEXT
          )
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
          DROP TABLE students;
          SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
        UPDATE students set name = ?
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.id)
  end 

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
end
