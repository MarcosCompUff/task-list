enum Tipo {work, selfCare, fitness, learn, errand}

class Task {
  int? id;
  late int user_id;
  late int board_id;
  late String title;
  late String note;
  late DateTime date;
  late DateTime startTime;
  late DateTime endTime;
  int? isCompleted;


  Task(this.title, this.board_id, {isCompleted = 0});

  Task.fromMap(Map map) {
    this.id = map["id"];
    this.user_id = map["user_id"];
    this.board_id = map["board_id"];
    this.title = map["title"];
    this.note = map["note"];
    this.date = map["date"];
    this.startTime = map["startTime"];
    this.endTime = map["endTime"];
    this.isCompleted = map["isCompleted"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "user_id": this.user_id,
      "board_id": this.board_id,
      "title": this.title,
      "note": this.note,
      "date": this.date,
      "startTime": this.startTime,
      "endTime": this.endTime,
      "isCompleted": this.isCompleted
    };

    if (this.id != null) {
      map["id"] = this.id;
    }
    return map;
  }
}