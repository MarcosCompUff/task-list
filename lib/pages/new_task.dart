import "dart:async";
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:task_list_db/model/task_board.dart';

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
  List<TaskBoard> taskBoardList = [];
  final TextEditingController _controllerTarefa = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  String startDate = "";
  String endDate = "";

  TaskBoard? selectedBoard;
  final _db = DbHelper();

  void getTaskBoards() async {
    List results = await _db.getTaskBoard();

    for (var item in results) {
      TaskBoard taskBoard = TaskBoard.fromMap(item);
      taskBoardList.add(taskBoard);
    }

    setState(() {
      selectedBoard = taskBoardList.first;
    });
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

    Task task = Task(
      title: taskTitle,
      note: note,
      date: DateTime.now().toString(),
      startTime: startDate,
      endTime: endDate,
      isCompleted: 0,
      userId: widget.userId,
      boardId: selectedBoard!.id!,
    );

    int result = await _db.insertTask(task);

    _controllerTarefa.clear();
    _controllerNote.clear();
    startDate = "";
    endDate = "";

    // Voltar para a tela anterior (DashboardPage)
    Navigator.pop(context, true);
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
    getTaskBoards();
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
      body: SingleChildScrollView(
        child: Padding(
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
                      const Text("Tipo da tarefa: "),
                      selectTaskTypeWidget(),
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
      ),
    );
  }

  Widget selectTaskTypeWidget() {
    return DropdownButton<TaskBoard>(
      value: selectedBoard,
      onChanged: (TaskBoard? newValue) {
        setState(() {
          selectedBoard = newValue!;
        });
      },
      items: taskBoardList.map<DropdownMenuItem<TaskBoard>>(
        (TaskBoard value) {
        return DropdownMenuItem<TaskBoard>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
