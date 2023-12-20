import 'package:flutter/material.dart';
import 'package:task_list_db/helper/db_helper.dart';
import 'package:task_list_db/model/user.dart';
import 'package:task_list_db/pages/login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _db = DbHelper();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Cadastro",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
                  controller: nameController,
                  decoration: const InputDecoration(
                    label: Text("Nome"),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    label: Text("Email"),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text("senha"),
                  ),
                ),
                TextField(
                  controller: passwordConfirmationController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text("confirme a senha"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Preencha todos os campos"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          User user = User(
                              nameController.text,
                              emailController.text,
                              passwordController.text
                          );
                          if (passwordController.text == passwordConfirmationController.text) {
                            _db.createUser(user, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Senhas não coincidem"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            debugPrint("Senhas não coincidem");
                          }
                        }
                      },
                      child: const Text("Criar conta")
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
