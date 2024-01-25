import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? cdb;

class DatabaseCreator {
  static const todoTable = 'cdb_videos';
  static const id = 'id';
  static const name = 'name';
  static const info = 'info';
  static const type = 'vtype';
  static const movieId = 'movie_id';
  static const tvSeriesId = 'tvseries_id';
  static const seasonId = 'season_id';
  static const episodeId = 'episode_id';
  static const dTaskId = 'dtask_id';
  static const dUserId = 'user_id';
  static const progress = 'progress';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>>? selectQueryResult,
      dynamic insertAndUpdateQueryResult,
      List<dynamic>? params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createTodoTable(Database db) async {
    final todoSql = '''CREATE TABLE $todoTable
    (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $name TEXT,
      $info TEXT,
      $type TEXT,
      $movieId TEXT,
      $tvSeriesId TEXT,
      $seasonId TEXT,
      $episodeId TEXT,
      $dTaskId TEXT,
      $dUserId TEXT,
      $progress INTEGER
    )''';

    await db.execute(todoSql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('cdb_videos_db');
    cdb = await openDatabase(path, version: 1, onCreate: onCreate);
    print(cdb);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTodoTable(db);
  }
}
