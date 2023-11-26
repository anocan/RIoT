import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:riot/classes/classes.dart' as rcc;
import 'package:riot/widgets/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rcc.getUserData(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          //NetworkImage(snapshot.data!.get('pp'))
          return const Text("");
        }

        if (snapshot.data!['userType'] == 'banned') {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignIn()));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false);
            final text = notificationBar(
              text: 'You have been restricted. Please consult the admin.',
            );
            ScaffoldMessenger.of(context).showSnackBar(text);
            return -1;
          });
        }
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
                      "Home",
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
                      ),
                    ]),
              ),
            ),
          ),
          body: Container(
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
                  0, MediaQuery.of(context).size.height * 0.2, 0, 0),
              child: Column(
                children: [
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('labData')
                          .doc('lab-data')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Column(
                            children: [
                              //CircularProgressIndicator(),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            rcc.HomeElement(
                              labData: snapshot.data!.get("labDoor"),
                              description: "Status of lab door",
                              icon: const Icon(Icons.door_front_door_outlined),
                            ),
                            rcc.HomeElement(
                              labData: snapshot.data!.get("labPeople"),
                              description: "Number of people",
                              icon: const Icon(Icons.people_alt_outlined),
                            ),
                            rcc.HomeElement(
                              labData: snapshot.data!.get("labWater"),
                              description: "Amount of water left",
                              icon: const Icon(Icons.water_drop_outlined),
                            ),
                            rcc.HomeElement(
                              labData: snapshot.data!.get("labCO2"),
                              description: "CO2 percentage",
                              icon: const Icon(Icons.co2_outlined),
                            ),
                          ],
                        );
                      })
                ],
              ),
            )),
          ),
        );
      },
    );
  }
}
