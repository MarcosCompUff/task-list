import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:task_list_db/helper/db_helper.dart';
import 'package:task_list_db/model/task_board.dart';

class NewTaskBoardPage extends StatefulWidget {
  const NewTaskBoardPage({super.key});

  @override
  State<NewTaskBoardPage> createState() => _NewTaskBoardPageState();
}

class _NewTaskBoardPageState extends State<NewTaskBoardPage> {

  Color c = Colors.black;
  Color currentColor = Colors.black;

  TextEditingController _controller = TextEditingController();

  final _db = DbHelper();

  createTaskBoard() async {
    String name = _controller.text;

    var t = TaskBoard(name: name, color: currentColor);

    await _db.insertTaskBoard(t);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.blueGrey,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: "Digite nome da board"),
                  controller: _controller,
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: showColorPicker, 
                    child: const Text("Selecionar cor")),
                ],
              ),
              ElevatedButton(
                onPressed: createTaskBoard, 
                child: const Text("Criar")
              )
            ],
          ),
        ),
      ),
    );
  }

  void showColorPicker() {
    showDialog(
      context: context,
      builder: (con) {
        return AlertDialog(
          actions: [
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = c);
                Navigator.of(context).pop();
              },
            )
          ],
          title: const Text("Escolha a cor"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: c,
              onColorChanged: (d) {
                setState(() {
                  c = d;
                });
              },
            ),
          ),
        );
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text("Criar board"),
      backgroundColor: Colors.blue,
    );
  }
}