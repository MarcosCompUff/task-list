import 'package:flutter/material.dart';
import 'package:task_list_db/helper/db_helper.dart';

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
        title: const Text("Cadastro"),
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
            decoration: const InputDecoration(
              label: Text("senha"),
            ),
          ),
          TextField(
            controller: passwordConfirmationController,
            decoration: const InputDecoration(
              label: Text("confirme a senha"),
            ),
          ),
          TextButton(
            onPressed: () {
              debugPrint("nome: ${emailController.text}\nemail: ${emailController.text}\nsenha: ${passwordController.text}\nconfirmação: ${passwordConfirmationController.text}");
            },
            child: const Text("Criar conta")
          )
        ],
      ),
    );
  }
}
