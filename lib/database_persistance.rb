require 'pg'

class DatabasePersistance
  def initialize(logger)
    @db = PG.connect(dbname: 'todos')
    @logger = logger
  end

  def query(sql, *params)
    @logger.info "#{sql}: #{params}"
    @db.exec_params(sql, params)
  end

  def find_list(list_id)
    sql = "SELECT * FROM lists WHERE id = $1;"
    result = query(sql, list_id)
    
    tuple = result.first
    { id: tuple["id"].to_i,
      name: tuple["name"],
      todos: find_todos(list_id) }
  end
  
  def lists
    sql = 'SELECT * FROM lists;'
    result = query(sql)
    
    result.map do |tuple|
      list_id = tuple["id"]

      { id: tuple["id"],
        name: tuple["name"],
        todos: find_todos(list_id) }
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
end