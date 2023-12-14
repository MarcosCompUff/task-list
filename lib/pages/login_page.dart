import 'package:flutter/material.dart';
import 'package:task_list_db/helper/db_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            obscureText: true,
            decoration: const InputDecoration(
              label: Text("senha"),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  if (await _db.loginUser(emailController.text, passwordController.text)) {
                    Navigator.pushNamed(context, "/dashboard");
                  }
                },
                  child: Text("Entrar")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/registration");
                },
                  child: const Text("Criar conta")
              ),
            ],
          ),
          ElevatedButton(onPressed: () {
              _db.printUsers();
            },
            child: const Text("Test...")
          )
        ],
      ),
    );
  }
}
