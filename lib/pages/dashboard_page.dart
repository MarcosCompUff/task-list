import "dart:async";
import 'package:flutter/material.dart';
import 'package:task_list_db/model/task_board.dart';
import 'package:task_list_db/pages/completed_task_page.dart';
import 'package:task_list_db/pages/new_task.dart';
import 'package:task_list_db/pages/new_taskboard_page.dart';
import 'package:task_list_db/pages/recente_task_page.dart';

import '../helper/db_helper.dart';
import '../model/task.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  final int userId;

  const DashboardPage({Key? key, required this.userId, required this.userEmail})
      : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Task> taskList = [];
  List<TaskBoard> taskBoardList = [];

  final _db = DbHelper();

  Future<List<Task>> getRecentTasks() async {
    DateTime now = DateTime.now();
    DateTime nextWeek = now.add(Duration(days: 7));

    List<Task> recentTasks = taskList.where((task) {
      String t = task.startTime;
      if(t == "") t = task.date;
      DateTime taskStartTime = DateTime.parse(t);
      return taskStartTime.isAfter(now) && taskStartTime.isBefore(nextWeek);
    }).toList();

    return recentTasks;
  }

  void _showRecentTasks() async {
    List<Task> recentTasks = await getRecentTasks();

    taskList.clear();
    setState(() {
      taskList = recentTasks;
    });
  }

  void getTasks() async {
    List results = await _db.getTasks();

    taskList.clear();

    for (var item in results) {
      Task task = Task.fromMap(item);
      taskList.add(task);
    }

    setState(() {});
  }

  void getTaskBoards() async {
    List results = await _db.getTaskBoard();

    taskBoardList.clear();

    for (var item in results) {
      TaskBoard taskBoard = TaskBoard.fromMap(item);
      taskBoardList.add(taskBoard);
    }

    setState(() {
      
    });
  }

  void showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes da Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tarefa: ${task.title}'),
                SizedBox(height: 8),
                Text('Nota: ${task.note}'),
                SizedBox(height: 8),
                Text('Data de Início: ${task.startTime}'),
                SizedBox(height: 8),
                Text('Data de Fim: ${task.endTime}'),
                SizedBox(height: 8),
                // Text('Tipo: ${getTypeName(task.boardId)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getTasks();
    getTaskBoards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              createBoard(),
              ...taskBoardList.map(taskBoardWidget)
            ],
          ),
        ),
      ),
    );
  }

  Widget createBoard() {
    return ListTile(
      leading: const Icon(Icons.add),
      title: const Text("Adicionar novo tipo"),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (c) => const NewTaskBoardPage())
        ).then((value) {
          if (value != null && value) {
            getTaskBoards();
          }
        });
      },
    );
  }

  Widget taskBoardWidget(TaskBoard taskBoard) {
    List<Task> t = taskList.where((element) => element.boardId == taskBoard.id).toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(4, 8)
            )
          ]),
        child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.delivery_dining_outlined, color: Colors.black),
                    Text(taskBoard.name),
                  ],
                ),
                Text("${t.length} tasks"),
              ],
            ),
            children: t.map(miniTaskWidget).toList()),
      ),
    );
  }

  Widget miniTaskWidget(Task task) {
    return ListTile(
      title: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Lista de Tarefas",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTaskPage(
                userId: widget.userId,
                userEmail: widget.userEmail,
              ),
            ),
          ).then((value) {
            if (value != null && value) {
              // Atualize a lista de tarefas após adicionar uma nova tarefa
              getTasks();
            }
          });
        },
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'Deslogar':
                _db.logoutUser(context);
                break;
              case 'Pesquisar':
                // TODO: Implemente a funcionalidade de pesquisa
                break;
              case 'Tarefas Recentes':
                _showRecentTasks();
                break;
              case 'Tarefas Concluídas':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedTasksPage(),
                  ),
                );
                break;
              default:
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Deslogar',
                child: Text('Deslogar'),
              ),
              const PopupMenuItem<String>(
                value: 'Pesquisar',
                child: Text('Pesquisar'),
              ),
              const PopupMenuItem<String>(
                value: 'Tarefas Recentes',
                child: Text('Tarefas Recentes'),
              ),
              const PopupMenuItem<String>(
                value: 'Tarefas Concluídas',
                child: Text('Tarefas Concluídas'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
