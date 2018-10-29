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

  def find_todos(list_id)
    sql = "SELECT * FROM todos WHERE id = $1"

    result = query(sql, list_id)
    result.map do |tuple|
      { id: tuple["id"].to_i,
        name: tuple["name"],
        completed: (tuple["completed"] == "t") }
    end
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
    # id = next_element_id(lists)
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def update_list_name(id, new_name)
    # list = find_list(id)
    # list[:name] = new_name
  end

  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end

  def create_todo(list_id, text)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    # list[:todos] << { id: id, name: text, completed: false }
  end
  
  def delete_todo(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # todo = list[:todos].find { |todo| todo[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def complete_all_todos!(list_id)
    # list = find_list(list_id)
    # list[:todos].each do |todo|
      # todo[:completed] = true
    # end
  end

  private

  
end