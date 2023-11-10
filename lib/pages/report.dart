import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:riot/classes/classes.dart' as rcc;

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const rcc.NavigationDrawer(),
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
                elevation: 0,
                leading: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 36,
                    )),
                backgroundColor: Colors.black87.withAlpha(45),
                title: const Text(
                  "Report",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withAlpha(120),
                    ),
                  )
                ]),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                themes.color1, //Color(0xff1f005c),
                themes.color2, //Color(0xff5b0060),
                themes.color3, //Color(0xff870160),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.05,
                      MediaQuery.of(context).size.height * 0.2,
                      MediaQuery.of(context).size.width * 0.05,
                      0),
                  child: const rcc.ReportMenu(),
                ),
              ),
            );
          }),
    );
  }
}
