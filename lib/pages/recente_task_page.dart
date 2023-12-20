import 'package:flutter/material.dart';
import 'package:task_list_db/model/task.dart';

class RecentTasksPage extends StatelessWidget {
  final List<Task> recentTasks;

  const RecentTasksPage({Key? key, required this.recentTasks})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Recentes'),
      ),
      body: ListView.builder(
        itemCount: recentTasks.length,
        itemBuilder: (context, index) {
          Task task = recentTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text('Data de Início: ${task.startTime}'),
            onTap: () {
              // Aqui você pode adicionar a lógica para mostrar detalhes da tarefa, se desejar
            },
          );
        },
      ),
    );
  }
}
