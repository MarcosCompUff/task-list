import 'package:flutter/material.dart';

import '../helper/db_helper.dart';
import '../model/task.dart';

class CompletedTasksPage extends StatelessWidget {
  final DbHelper _db = DbHelper(); // Instância do banco de dados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Concluídas'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _db.getCompletedTasks(), // Obtendo tarefas concluídas
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar tarefas concluídas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma tarefa concluída'));
          } else {
            // Mostrar a lista de tarefas concluídas
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return ListTile(
                  title: Text(task.title),
                  // Mais detalhes ou ações específicas da tarefa concluída podem ser adicionados aqui
                );
              },
            );
          }
        },
      ),
    );
  }
}
