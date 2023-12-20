import 'dart:io';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_list_db/model/user.dart';

import '../helper/db_helper.dart';
import '../model/task.dart';

class NewTaskPage extends StatefulWidget {
  final String userEmail;
  final int userId;

  const NewTaskPage({super.key, required this.userId, required this.userEmail});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
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

  void buildInsertUpdate(String operation, {int index = -1}) async {
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
        "Nova tarefa",
        style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
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
                  decoration: const InputDecoration(labelText: "Descrição"),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _controllerStartDate,
                  decoration:
                      const InputDecoration(labelText: "Data de Início"),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _controllerEndDate,
                  decoration: const InputDecoration(labelText: "Data de Fim"),
                  onChanged: (text) {},
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        debugPrint("adicionar tarefa");
                        _saveTarefa();
                      },
                      child: const Text("Adicionar Tarefa"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
