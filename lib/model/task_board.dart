import 'package:flutter/material.dart';

class TaskBoard {
  int? id;
  String name;
  Color color;

  TaskBoard({
    this.id,
    required this.name,
    required this.color
  });

  // Factory constructor para criar uma instância de Task a partir de um mapa
  factory TaskBoard.fromMap(Map<String, dynamic> map) {
    int c = map['color'];
    return TaskBoard(
      id: map['id'],
      name: map['name'],
      color: Color.fromARGB(
        (c&0xFF000000) >> 24,
        (c&0x00FF0000) >> 16,
        (c&0x0000FF00) >> 8 ,
        (c&0x000000FF) >> 0 )
    );
  }

  // Método para converter a tarefa em um mapa para armazenamento no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': _colorToInt()
    };
  }

  int _colorToInt() {
    return (
      (color.alpha) << 24 |
      (color.red  ) << 16 |
      (color.green) << 8  |
      (color.blue ) << 0
    );
  }
}
