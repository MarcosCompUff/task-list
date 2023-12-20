import 'dart:io';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  String startDate = "";
  String endDate = "";

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
    String startDate = this.startDate;
    String endDate = this.endDate;
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
    startDate = "";
    endDate = "";

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
    String startDate = this.startDate;
    String endDate = this.endDate;

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

  void _onSelectionChange(DateRangePickerSelectionChangedArgs data) {
    DateTime startDate = data.value.startDate;
    late DateTime endDate;
    if (data.value.endDate == null) {
      endDate = startDate;
    } else {
      endDate = data.value.endDate;
    }

    String dataInicialFormatada = "${startDate.day}/${startDate.month}/${startDate.year}";
    String dataFinalFormatada = "${endDate.day}/${endDate.month}/${endDate.year}";

    this.startDate = dataInicialFormatada;
    this.endDate = dataFinalFormatada;

    debugPrint(this.startDate);
    debugPrint(this.endDate);
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
      backgroundColor: Colors.blueGrey,
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
                const SizedBox(height: 20,),
                const Text("Selecione as datas de início e fim da tarefa"),
                SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged: _onSelectionChange,
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
