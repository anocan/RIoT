import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBar(
        title: const Text('a'),
      ),
      floatingActionButton: TextButton(
        child: const Text('aASDASDAD'),
        onPressed: () {
          final snackBar = SnackBar(
            content: const Text(
              'aaa',
              style: TextStyle(color: Colors.red),
            ),
            action: SnackBarAction(label: 'undo', onPressed: () {}),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      ),
    );
  }
}
