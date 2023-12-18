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
    return FutureBuilder<bool?>(future: _db.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // TODO: mandar pra dashboard page
            final SharedPreferences prefs = await SharedPreferences.getInstance();

            final String? userEmail = prefs.getString('email');
            final int? userId = prefs.getInt('id');

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardPage(userId: userId!, userEmail: userEmail!)
              ),
              (route) => false,
            );
          });
          return Container();
        } else {
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
                ElevatedButton(
                  onPressed: () {
                    _db.printUsers();
                  },
                  child: const Text("Test...")
                )
              ],
            ),
          );
        }
      },
    );
  }
}
