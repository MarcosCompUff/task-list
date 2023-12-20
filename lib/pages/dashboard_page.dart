import 'dart:io';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_list_db/model/user.dart';
import 'package:task_list_db/pages/completed_task_page.dart';
import 'package:task_list_db/pages/new_task.dart';

import '../helper/db_helper.dart';
import '../model/task.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  final int userId;

  const DashboardPage(
      {super.key, required this.userId, required this.userEmail});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Task> taskList = [];
  TextEditingController _controllerTarefa = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  TextEditingController _controllerStartDate = TextEditingController();
  TextEditingController _controllerEndDate = TextEditingController();
  String selectedType = 'Work';
  final _db = DbHelper();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint("Path: ${dir.path}");

    return File("${dir.path}/data.json");
  }

  Future<DateTime?> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    return picked;
  }

  Future<DateTime?> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    return picked;
  }

  _saveTarefa() async {
    String taskTitle = _controllerTarefa.text;
    String note = _controllerNote.text;
    String startDate = _controllerStartDate.text;
    String endDate = _controllerEndDate.text;
    int boardId;

    switch (selectedType) {
      case 'Work':
        boardId = Tipo.work.index;
        break;
      case 'Self Care':
        boardId = Tipo.selfCare.index;
        break;
      case 'Fitness':
        boardId = Tipo.fitness.index;
        break;
      case 'Learn':
        boardId = Tipo.learn.index;
        break;
      case 'Errand':
        boardId = Tipo.errand.index;
        break;
      default:
        boardId = Tipo.work.index;
        break;
    }

    Task task = Task(
      title: taskTitle,
      note: note,
      date: DateTime.now().toString(),
      startTime: startDate,
      endTime: endDate,
      isCompleted: 0,
      userId: widget.userId,
      boardId: boardId,
    );

    int result = await _db.insertTask(task);

    // Atualize a lista de tarefas após a inserção
    getTasks();

    // Limpe os campos de entrada após salvar a tarefa
    _controllerTarefa.clear();
    _controllerNote.clear();
    _controllerStartDate.clear();
    _controllerEndDate.clear();

    // Voltar para a tela anterior (DashboardPage)
    Navigator.pop(context, true);
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

  _updateTarefa(int index) async {
    String taskTitle = _controllerTarefa.text;
    String note = _controllerNote.text;
    String startDate = _controllerStartDate.text;
    String endDate = _controllerEndDate.text;

    Task task = taskList[index];
    task.title = taskTitle;
    task.note = note;
    task.startTime = startDate;
    task.endTime = endDate;

    int result = await _db.updateTask(task);
    getTasks();
    setState(() {});
  }

  _saveFile() async {
    /*final file = await _getFile();
    String data = jsonEncode(_listaTarefas);
    file.writeAsString(data);
    */
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void buildInsertUpdate(String operation, {int index = -1}) {
    String label = "Salvar";
    String note = "";
    String startDate = "";
    String endDate = "";

    if (operation == "atualizar") {
      label = "Atualizar";
      _controllerTarefa.text = taskList[index].title;
      note = taskList[index].note;
      startDate = taskList[index].startTime;
      endDate = taskList[index].endTime;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$label Tarefa"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controllerTarefa,
                  decoration:
                      const InputDecoration(labelText: "Digite sua tarefa"),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _controllerNote,
                  decoration: const InputDecoration(labelText: "Nota"),
                  onChanged: (text) {},
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await _selectStartDate(context);
                    if (pickedDate != null) {
                      setState(() {
                        _controllerStartDate.text = pickedDate.toString();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _controllerStartDate,
                      decoration:
                          const InputDecoration(labelText: "Data de Início"),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await _selectEndDate(context);
                    if (pickedDate != null) {
                      setState(() {
                        _controllerEndDate.text = pickedDate.toString();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _controllerEndDate,
                      decoration:
                          const InputDecoration(labelText: "Data de Fim"),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Tipo da tarefa: "),
                    DropdownButton<String>(
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                      items: <String>[
                        'Work',
                        'Self Care',
                        'Fitness',
                        'Learn',
                        'Errand'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (operation == "atualizar") {
                  _updateTarefa(index);
                } else {
                  _saveTarefa();
                }
                Navigator.pop(context);
              },
              child: Text(label),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    /*_readFile().then((data) {
      setState(() {
        _listaTarefas = jsonDecode(data);
      });
    });*/
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.add),
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
                  // Implemente a funcionalidade de pesquisa
                  break;
                case 'Tarefas Recentes':
                  // Implemente a exibição de tarefas recentes
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
      ),
      backgroundColor: Colors.blueGrey,
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                    background: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.green,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.red,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Excluir Tarefa
                        Task task = taskList[index];
                        int result = await _db.deleteTask(task.id!);
                        taskList.removeAt(index);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tarefa excluída')),
                        );
                      } else if (direction == DismissDirection.startToEnd) {
                        // Atualizar Tarefa
                        buildInsertUpdate("atualizar", index: index);
                      }
                    },
                    child: CheckboxListTile(
                      title: Text(taskList[index].title),
                      value: taskList[index].isCompleted == 1,
                      onChanged: (bool? newVal) async {
                        int newStatus = newVal!
                            ? 1
                            : 0; // Define o novo status com base no valor do checkbox
                        Task task = taskList[index];
                        task.isCompleted = newStatus;

                        await _db.updateTask(
                            task); // Atualiza o status da tarefa no banco de dados
                        getTasks(); // Atualiza a lista de tarefas após a mudança

                        setState(() {}); // Atualiza a interface gráfica
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
