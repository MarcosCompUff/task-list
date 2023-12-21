class Task {
  int? id;
  int userId;
  int boardId;
  String title;
  String note;
  String date;
  String startTime;
  String endTime;
  int isCompleted;

  Task({
    this.id,
    required this.userId,
    required this.boardId,
    required this.title,
    required this.note,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
  });

  // Factory constructor para criar uma instância de Task a partir de um mapa
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      boardId: map['board_id'],
      title: map['title'],
      note: map['note'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      isCompleted: map['isCompleted'],
    );
  }

  // Método para converter a tarefa em um mapa para armazenamento no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'board_id': boardId,
      'title': title,
      'note': note,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'isCompleted': isCompleted,
    };
  }
}
