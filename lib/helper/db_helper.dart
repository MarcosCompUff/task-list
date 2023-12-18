import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_list_db/model/user.dart';
import 'package:task_list_db/pages/dashboard_page.dart';
import '../model/task.dart';

class DbHelper {
  static Database? _db;
  static final DbHelper _dbHelper = DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  DbHelper._internal();

  initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "task.db");

    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDb
    );

    return db;

  }

  void _onCreateDb(Database db, int version) {
    String userSql = """
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        email VARCHAR NOT NULL,
        password VARCHAR NOT NULL
      );
    """;

    String taskboardSql = """
      CREATE TABLE task_board(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        color INTEGER NOT NULL
      );
    """;

    String taskSql = """
      CREATE TABLE task(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        board_id INTEGER NOT NULL,
        title VARCHAR NOT NULL,
        note TEXT NOT NULL,
        date VARCHAR NOT NULL,
        startTime VARCHAR NOT NULL,
        endTime VARCHAR NOT NULL,
        isCompleted INTEGER,
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(board_id) REFERENCES task_board(id)
      );
    """;

    db.execute(userSql);
    db.execute(taskboardSql);
    db.execute(taskSql);
  }

  Future<Database?> get db async {
    /*if (_db == null) {
      _db = initDb();
    }*/

    _db ??= await initDb();

    return _db;
  }

  Future<int> insertTask(Task task) async {
    var database = await db;
    debugPrint("Insert Task");

    int result = await database!.insert(
      "task",
      task.toMap()
    );

    return result;
  }

  Future<int> updateTask(Task task) async {
    var database = await db;

    int result = await database!.update(
      "task",
      task.toMap(),
      where: "id=?",
      whereArgs: [task.id]
    );

    return result;
  }

  Future<int> deleteTask(int id) async {
    var database = await db;

    int result = await database!.delete(
      "task",
      where: "id=?",
      whereArgs: [id]
    );

    return result;
  }

  getTasks() async {
    var database = await db;

    String sql = "SELECT * FROM task;";

    List results = await database!.rawQuery(sql);

    return results;
  }

  Future<int> createUser(User user) async {
    var database = await db;
    debugPrint("Create User");

    bool emailAlreadyExists = await isEmailAlreadyRegistered(user.email);

    if (emailAlreadyExists) {
      debugPrint("E-mail já cadastrado!");
      // TODO: mostrar mensagem: email já cadastrado
      return -1;
    }

    int result = await database!.insert(
      "user",
      user.toMap(),
    );

    debugPrint("Result: $result");
    return result;
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    var database = await db;

    List<Map> result = await database!.query(
      'user',
      columns: ['email'],
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<bool> loginUser(String email, String password, BuildContext context) async {
    var database = await db;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map> userResult = await database!.query(
      'user',
      columns: ['email', 'password'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (userResult.isEmpty) {
      // TODO: mostrar mensagem: email não encontrado
      debugPrint("E-mail não encontrado!");
      return false;
    }

    String storedPassword = userResult.first['password'].toString();
    int storeId = userResult.first['id'];

    if (storedPassword == password) {
      prefs.setInt('logged', 1);
      prefs.setString('email', email);
      debugPrint("Login bem-sucedido!");
      Future.delayed(Duration.zero, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage(userId: storeId, userEmail: email)));
      });
      return true;
    } else {
      // TODO: mostrar mensagem: senha incorreta
      debugPrint("Senha incorreta!");
      return false;
    }
  }

  Future<bool?> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('repeat');
  }

  printUsers() async {
    var database = await db;

    String sql = "SELECT * FROM user;";

    List results = await database!.rawQuery(sql);

    debugPrint("Users: $results");
  }
}