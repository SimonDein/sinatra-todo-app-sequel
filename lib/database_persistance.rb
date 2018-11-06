require 'pg'

class DatabasePersistance
  def initialize(logger)
    if Sinatra::Base.production?
      @db = PG.connect(ENV["DATABASE_URL"])
    else
      @db = PG.connect(dbname: "todos")
    end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def find_list(list_id)
    sql = <<~SQL
        SELECT lists.*,
               COUNT(todos.id)                      AS todos_count,
               COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
          FROM lists
               LEFT OUTER JOIN todos
               ON lists.id = todos.list_id
         WHERE lists.id = $1
      GROUP BY lists.id;
    SQL
    
    result = query(sql, list_id)
    
    tuple = result.first
    { id: tuple["id"].to_i,
      name: tuple["name"],
      todos_count: tuple["todos_count"].to_i,
      todos_remaining_count: tuple["todos_remaining_count"].to_i,
      todos: find_todos(list_id) }
  end
  
  def lists
    sql = <<~SQL
               SELECT lists.*,
                      COUNT(todos.id) AS todos_count,
                      COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
                 FROM lists
      LEFT OUTER JOIN todos
                   ON lists.id = todos.list_id
             GROUP BY lists.id
             ORDER BY lists.name;
    SQL
    
    result = query(sql)
    result.map do |tuple|
      { id: tuple["id"].to_i,
        name: tuple["name"],
        todos_count: tuple["todos_count"].to_i,
        todos_remaining_count: tuple["todos_remaining_count"].to_i }
    end
  end

  def create_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, id)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def create_todo(list_id, text)
    sql = "INSERT INTO todos (list_id, name) VALUES ($1, $2)"
    query(sql, list_id, text)
  end
  
  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE list_id = $1 AND id = $2"
    query(sql, list_id, todo_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE list_id = $2 AND id = $3"
    query(sql, new_status, list_id, todo_id)
  end

  def complete_all_todos!(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

  private

  def find_todos(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"

    result = query(sql, list_id)
    result.map do |tuple|
      { id: tuple["id"].to_i,
        name: tuple["name"],
        completed: (tuple["completed"] == "t") }
    end
  end

  def query(sql, *params)
    @logger.info "#{sql}: #{params}"
    @db.exec_params(sql, params)
  end
end