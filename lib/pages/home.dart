import 'dart:io';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../helper/db_helper.dart';
import '../model/task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //List<Map<String, dynamic>> _listaTarefas = [];
  List<Task> taskList = [];
  final TextEditingController _controllerTarefa = TextEditingController();
  final _db = DbHelper();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint("Path: ${dir.path}");

    return File("${dir.path}/data.json");
  }

  /* Implementar função abaixo  */
  _saveTarefa() async {
    String taskStr = _controllerTarefa.text;

    /*Map<String, dynamic> task = {
      "title": taskStr,
      "done": false
    };*/
    Task task = Task(taskStr);
    task.done = 0;
    taskList.add(task);
    debugPrint("SaveTarefa: ${task.title}, ${task.done}");
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
        content: TextField(
            controller: _controllerTarefa,
            decoration:
                const InputDecoration(labelText: "Digite sua tarefa"),
            onChanged: (text) {}),
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
              child: Text(label)),
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
        title: const Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          buildInsertUpdate("inserir");
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
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
                        )
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
                        )
                      ),
                      onDismissed: (direction) async{
                        print(direction);

                        if (direction == DismissDirection.endToStart) {
                          // Excluir Tarefa
                          Task task = taskList[index];
                          int result = await _db.deleteTask(task.id!);
                          taskList.removeAt(index);
                          setState(() {
                            
                          });
                          //_saveFile();
                        } else if (direction == DismissDirection.startToEnd) {
                          // Atualizar Tarefa

                          buildInsertUpdate("atualizar", index: index);
                        }
                      },
                      child: CheckboxListTile(
                        title: Text(taskList[index].title),
                        value: taskList[index].done==1,
                        onChanged: (bool? newVal) async{
                          Task task = taskList[index];

                          if (newVal == true) {
                            task.done = 1;
                          } else {
                            task.done = 0;
                          }

                          int result = await _db.updateTask(task);
                          
                          setState(() {
                            
          
                          });
                          //_saveFile();
                        },
                      )  
                    );
                    
                    
                  }))
        ]),
      ),
    );
  }
}
