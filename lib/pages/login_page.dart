import 'package:flutter/material.dart';
import 'package:task_list_db/helper/db_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _loginPageState();
}

class _loginPageState extends State<LoginPage> {
  final _db = DbHelper();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              label: Text("email"),
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              label: Text("senha"),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                debugPrint("email: ${emailController.text}\nsenha: ${passwordController.text}");
              },
              child: Text("Entrar")
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/registration");
              },
              child: const Text("Criar conta")
          )
        ],
      ),
    );
  }
}
