/// RIoT
/// Custom
/// Classes
/// (rcc)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riot/pages/home.dart';
import 'package:riot/pages/profile.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riot/themes/themes.dart' as themes;

class User {
  /// id
  String id;
  final String userName;
  final String email;
  final String name;
  final String pp; // Profile Picture
  final String phoneNumber;
  final String gender;
  final String dob; // Date of Birth
  final String country;
  final String cot; // Coffee or Tea?
  final String favProfessor;
  final String department;

  User({
    required this.userName,
    required this.email,
    this.id = '',
    this.name = '',
    this.pp = '',
    this.phoneNumber = '',
    this.gender = '',
    this.dob = '',
    this.country = '',
    this.cot = '',
    this.favProfessor = '',
    this.department = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'email': email,
        'name': name,
        'pp': pp,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dob': dob,
        'country': country,
        'cot': cot,
        'favProfessor': favProfessor,
        'department': department,
      };
}

class LocalException {
  String exception;

  LocalException({required this.exception}) {
    exception = _parseString(exception);
  }

  String _parseString(String exception) {
    return exception.substring(0);
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
          child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
          themes.color1, //Color(0xff1f005c),
          themes.color2, //Color(0xff5b0060),
          themes.color3, //Color(0xff870160),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      ));

  Widget buildHeader(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Profile()));
          },
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Container(
                  padding: EdgeInsets.only(
                      top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              AssetImage("assets/images/default-pp.jpg")),
                      const SizedBox(height: 24),
                      Text(
                        "Hello, ${snapshot.data!.get('userName') ?? ''}",
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
        ),
      );
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 8,
          children: [
            generateMenuItem(
                context: context,
                text: "Home",
                icon: Icons.home_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const Home()));
                }),
            const SizedBox(height: 120),
            generateMenuItem(
                context: context,
                text: "Log Out",
                icon: Icons.exit_to_app_rounded,
                onTap: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Logged Out Succesfully"); // WIP
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignIn()));
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignIn()),
                        (route) => false);
                  });
                },
                isLogOut: true),
          ],
        ),
      );
}
