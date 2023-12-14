import 'package:flutter/material.dart';
import 'package:task_list_db/helper/db_helper.dart';
import 'package:task_list_db/model/user.dart';

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
              debugPrint("nome: ${emailController.text}\nemail: ${emailController.text}\nsenha: ${passwordController.text}\nconfirmação: ${passwordConfirmationController.text}");
              User user = User(
                nameController.text,
                emailController.text,
                passwordController.text
              );
              if (passwordController.text == passwordConfirmationController.text) {
                _db.createUser(user);
              } else {
                debugPrint("Senhas não coincidem");
                // TODO: impedir que seja criada conta se algum campo estiver vazio
                // TODO: mostrar mensagem dizendo que as senhas não coincidem
              }
              // TODO: mostrar feedback de conta criada comsucesso e voltar pra página de login
            },
            child: const Text("Criar conta")
          )
        ],
      ),
    );
  }
}
