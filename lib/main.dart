import 'package:flutter/material.dart';
import 'package:task_list_db/pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/registration_page.dart';

void main() {
  runApp(MaterialApp(
    title: "Shared Preferences",
    debugShowCheckedModeBanner: false,
    home: const LoginPage(),
    routes: {
      '/login': (context) => const LoginPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/registration': (context) => const RegistrationPage(),
    },
  ));
}
