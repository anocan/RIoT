import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/sign_in.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: const Text('Logout'),
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value) {
            print("Logged Out Succesfully"); // WIP
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignIn()));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false);
          });
        },
      )),
    );
  }
}
