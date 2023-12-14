class User {
  int? id;
  late String name;
  late String email;
  late String password;

  User(this.name, this.email, this.password);

  User.fromMap(Map map) {
    this.id = map["id"];
    this.name = map["name"];
    this.email = map["email"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "password": this.password
    };

    if (this.id != null) {
      map["id"] = this.id;
    }
    return map;
  }
}