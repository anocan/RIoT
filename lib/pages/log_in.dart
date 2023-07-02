import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Image(
      color: Colors.red,
      image: NetworkImage(
          'https://upload.wikimedia.org/wikipedia/commons/6/61/Wikipedia-logo-transparent.png'),
      width: 100,
      height: 2000,
    ));
  }
}
