import '/common/global.dart';
import '/models/todo.dart';
import '/services/repository/database_creator.dart';

class RepositoryServiceTodo {
  static Future<List<Todo>> getAllTodos() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}''';

    final data = await cdb!.rawQuery(sql);

    for (final node in data) {
      final todo = Todo.fromMap(node);
      todos.add(todo);
    }
    return todos;
  }

  static Future<List<Todo>> getAllTodos2() async {
    var response = await cdb!.query(DatabaseCreator.todoTable);
    todos = response.map((c) => Todo.fromMap(c)).toList();
    return todos;
  }

  static Future<Todo> getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await cdb!.rawQuery(sql, params);

    final todo = Todo.fromMap(data.first);
    return todo;
  }

  static Future<void> addTodo(Todo todo) async {
    final sql = '''INSERT INTO ${DatabaseCreator.todoTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.info},
      ${DatabaseCreator.type},
      ${DatabaseCreator.movieId},
      ${DatabaseCreator.tvSeriesId},
      ${DatabaseCreator.seasonId},
      ${DatabaseCreator.episodeId},
      ${DatabaseCreator.dTaskId},
      ${DatabaseCreator.dUserId},
      ${DatabaseCreator.progress}
    )
    VALUES (?,?,?,?,?,?,?,?,?,?,?)''';
    List<dynamic> params = [
      todo.id,
      todo.name,
      todo.path,
      todo.type,
      todo.movieId,
      todo.tvSeriesId,
      todo.seasonId,
      todo.episodeId,
      todo.dTaskId,
      todo.dUserId,
      todo.progress
    ];

    final result = await cdb!.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add todo', sql, null, result, params);
  }

  static Future<void> deleteTodo(Todo todo) async {
    await cdb!.delete(DatabaseCreator.todoTable);
  }

  static Future<void> updateTodo(Todo todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.name} = ?
    WHERE ${DatabaseCreator.id} = ?
    ''';

    List<dynamic> params = [todo.name, todo.id];
    final result = await cdb!.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update todo', sql, null, result, params);
  }

  static Future<int> todosCount() async {
    final data = await cdb!
        .rawQuery('''SELECT COUNT(*) FROM ${DatabaseCreator.todoTable}''');
    int count = data[0].values.elementAt(0) as int;
    int idForNewItem = count++;
    return idForNewItem;
  }
}
