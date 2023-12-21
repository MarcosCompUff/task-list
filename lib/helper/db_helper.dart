import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_list_db/model/task_board.dart';
import 'package:task_list_db/model/user.dart';
import 'package:task_list_db/pages/dashboard_page.dart';
import 'package:task_list_db/pages/login_page.dart';
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

    Database db = await openDatabase(path, version: 1, onCreate: _onCreateDb);
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

    insertTaskBoard(TaskBoard(name: "Work",       color: Colors.redAccent));
    insertTaskBoard(TaskBoard(name: "Self Care",  color: Colors.yellowAccent));
    insertTaskBoard(TaskBoard(name: "Fitness",    color: Colors.greenAccent));
    insertTaskBoard(TaskBoard(name: "Learn",      color: Colors.blueAccent));
    insertTaskBoard(TaskBoard(name: "Errand",     color: Colors.brown));
  }

  Future<Database?> get db async {
    /*if (_db == null) {
      _db = initDb();
    }*/

    _db ??= await initDb();

    return _db;
  }

  Future<int> insertTaskBoard(TaskBoard board) async {
    var database = await db;
    debugPrint("Insert Board");

    int result = await database!.insert("task_board", board.toMap());

    return result;
  }

  Future<List<Map<String, dynamic>>> getTaskBoard() async {
    var database = await db;

    String sql = "SELECT * FROM task_board;";
    var r = await database!.rawQuery(sql);
    return r;
  }

  Future<int> insertTask(Task task) async {
    var database = await db;
    debugPrint("Insert Task");

    int result = await database!.insert("task", task.toMap());

    return result;
  }

  Future<int> updateTask(Task task) async {
    var database = await db;

    int result = await database!
        .update("task", task.toMap(), where: "id=?", whereArgs: [task.id]);

    return result;
  }

  Future<int> deleteTask(int id) async {
    var database = await db;

    int result = await database!.delete("task", where: "id=?", whereArgs: [id]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    var database = await db;

    String sql = "SELECT * FROM task WHERE isCompleted = 0;";
    List<Map<String, dynamic>> results = await database!.rawQuery(sql);

    return results;
  }

  Future<List<Task>> getCompletedTasks() async {
    var database = await db;

    String sql = "SELECT * FROM task WHERE isCompleted = 1;";

    List<Map<String, dynamic>> results = await database!.rawQuery(sql);

    List<Task> completedTasks = results.map((taskMap) {
      return Task.fromMap(taskMap);
    }).toList();

    return completedTasks;
  }

  Future<int> createUser(User user, BuildContext context) async {
    var database = await db;
    debugPrint("Create User");

    bool emailAlreadyExists = await isEmailAlreadyRegistered(user.email);

    if (emailAlreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email já cadastrado"),
          duration: Duration(seconds: 2),
        ),
      );
      return -1;
    }

    int result = await database!.insert(
      "user",
      user.toMap(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Usuário cadastrado com sucesso"),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
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

  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    var database = await db;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map> userResult = await database!.query(
      'user',
      columns: ['email', 'password', 'id'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (userResult.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email não encontrado"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    String storedPassword = userResult.first['password'].toString();
    int storeId = userResult.first['id'];

    if (storedPassword == password) {
      prefs.setBool('isLogged', true);
      prefs.setInt('id', storeId);
      prefs.setString('email', email);
      debugPrint("Login bem-sucedido!");
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DashboardPage(userId: storeId, userEmail: email)),
          (route) => false,
        );
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Senha incorreta"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogged', false);
    await prefs.remove('id');
    await prefs.remove('email');

    Future.delayed(Duration.zero, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    });
  }

  Future<bool?> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isLogged');
  }

  printUsers() async {
    var database = await db;

    String sql = "SELECT * FROM user;";

    List results = await database!.rawQuery(sql);

    debugPrint("Users: $results");
  }
}
