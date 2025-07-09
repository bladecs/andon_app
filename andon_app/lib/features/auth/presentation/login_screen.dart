import 'package:flutter/material.dart';
import './widgets/login_form.dart';
import './widgets/login_header.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoginHeader(),
                SizedBox(height: 32),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}