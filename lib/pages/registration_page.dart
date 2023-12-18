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
      appBar: AppBar(
        title: const Text(
          "Cadastro",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                  _db.createUser(user);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Usuário cadastrado com sucesso"),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage()
                    ),
                        (route) => false,
                  );
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
          )
        ],
      ),
    );
  }
}
