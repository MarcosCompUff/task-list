import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_list_db/helper/db_helper.dart';
import 'package:task_list_db/pages/dashboard_page.dart';

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
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
                  _db.loginUser(emailController.text, passwordController.text, context);
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
