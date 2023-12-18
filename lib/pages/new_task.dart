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
  final TextEditingController _controllerTarefa = TextEditingController();
  Tipo tipo = Tipo.work;
  final _db = DbHelper();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint("Path: ${dir.path}");

    return File("${dir.path}/data.json");
  }

  /* Implementar função abaixo  */
  _saveTarefa() async {
    String taskStr = _controllerTarefa.text;
    int board_id = tipo.index;

    /*Map<String, dynamic> task = {
      "title": taskStr,
      "done": false
    };*/
    Task task = Task(taskStr, board_id);
    task.isCompleted = 0;
    taskList.add(task);
    debugPrint("SaveTarefa: ${task.title}, ${task.isCompleted}");
    int result = await _db.insertTask(task);
    debugPrint("id: $result");
    getTasks();
    /*setState(() {
      //_listaTarefas.add(task);
    });*/

    ///_saveFile();
  }

  void getTasks() async {
    List results = await _db.getTasks();

    taskList.clear();

    for (var item in results) {
      Task task = Task.fromMap(item);
      taskList.add(task);
    }

    setState(() {

    });
  }

  _updateTarefa(int index) async {
    String taskStr = _controllerTarefa.text;

    //Map<String, dynamic> task = _listaTarefas[index];
    //task["title"] = taskStr;
    Task task = taskList[index];
    task.title = taskStr;

    int result = await _db.updateTask(task);
    //getTasks();
    setState(() {

    });

    //_saveFile();
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
    if (operation == "atualizar") {
      label = "Atualizar";
      _controllerTarefa.text = taskList[index].title;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$label Tarefa"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _controllerTarefa,
                    decoration: const InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {}
                ),
                Row(
                  children: [
                    const Text("Tipo da tarefa: "),
                    DropdownButton<Tipo>(
                      value: tipo,
                      onChanged: (Tipo? newValue) {
                        setState(() {
                          tipo = newValue!;
                        });
                      },
                      items: Tipo.values.map((Tipo type) {
                        return DropdownMenuItem<Tipo>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar")),
              TextButton(
                  onPressed: () {

                    if (operation == "atualizar") {
                      _updateTarefa(index);
                    } else {
                      _saveTarefa();
                    }

                    Navigator.pop(context);
                  },
                  child: Text(label)
              ),
            ],
          );
        });
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
          "Nova Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        actions: [
          TextButton(
            onPressed: () {
              _db.logoutUser(context);
            },
            child: const Text(
              "Sair",
              style: TextStyle(color: Colors.white),
            )
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _controllerTarefa,
              decoration: const InputDecoration(labelText: "Digite sua tarefa"),
              onChanged: (text) {}
          ),
          Row(
            children: [
              const Text("Tipo da tarefa: "),
              DropdownButton<Tipo>(
                value: tipo,
                onChanged: (Tipo? newValue) {
                  setState(() {
                    tipo = newValue!;
                  });
                },
                items: Tipo.values.map((Tipo type) {
                  return DropdownMenuItem<Tipo>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
