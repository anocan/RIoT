/// RIoT
/// Custom
/// Classes
/// (rcc)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:riot/pages/home.dart';
import 'package:riot/pages/profile.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riot/themes/themes.dart' as themes;

class User {
  String id;
  final String userType;
  final String userName;
  final String email;
  final String name;
  late final String pp; // Profile Picture
  final String phoneNumber;
  final String gender;
  final String dob; // Date of Birth
  final String country;
  final String cot; // Coffee or Tea?
  final String department;

  User({
    required this.userName,
    required this.email,
    required this.userType,
    this.id = '',
    this.name = '',
    this.pp = '',
    this.phoneNumber = '',
    this.gender = '',
    this.dob = '',
    this.country = '',
    this.cot = '',
    this.department = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userType': userType,
        'userName': userName,
        'email': email,
        'name': name,
        'pp': pp,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dob': dob,
        'country': country,
        'cot': cot,
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
                      CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              NetworkImage(snapshot.data!.get('pp'))),
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
  Widget buildMenuItems(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docUser = FirebaseFirestore.instance.collection('users').doc(userId);
    final docData = docUser.get().then((value) {
      Map data = value.data() as Map;
      return data;
    });
    return Container(
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignIn()));
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
}

class ElementPicker extends StatefulWidget {
  final List<String> items;
  final String updateItem;
  const ElementPicker({Key? key, required this.items, required this.updateItem})
      : super(key: key);

  @override
  State<ElementPicker> createState() => _ElementPickerState();
}

class _ElementPickerState extends State<ElementPicker> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.72,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                color: Colors.transparent),
            child: CupertinoPicker(
              diameterRatio: 1,
              backgroundColor: Colors.transparent,
              itemExtent: 64,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: widget.items
                  .map((e) => Center(
                          child: Text(
                        e,
                        textAlign: TextAlign.center,
                      )))
                  .toList(),
            ),
          ),
          CupertinoButton(
            onPressed: () {
              switch (widget.updateItem) {
                case "cot":
                  updateUser(cot: widget.items[selectedIndex]);
                  break;
                case "gender":
                  updateUser(gender: widget.items[selectedIndex]);
                  break;
                case "department":
                  updateUser(department: widget.items[selectedIndex]);
                  break;
                case "country":
                  updateUser(country: widget.items[selectedIndex]);
                  break;
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Select",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  var selectedDate = DateTime(2000, 1, 1);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45), color: Colors.white),
        width: MediaQuery.of(context).size.width * 0.72,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Expanded(
              child: CupertinoDatePicker(
                backgroundColor: Colors.transparent,
                mode: CupertinoDatePickerMode.date,
                dateOrder: DatePickerDateOrder.ymd,
                initialDateTime: DateTime(2000, 1, 1),
                maximumDate: DateTime.now(),
                minimumDate: DateTime(1960, 1, 1),
                onDateTimeChanged: (DateTime time) {
                  setState(() {
                    selectedDate = time;
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                updateUser(
                    dob: selectedDate.toString().split(' ')[0].toString());
                Navigator.pop(context);
              },
              child: const Text(
                "Select",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
