import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:riot/classes/classes.dart' as rcc;
import 'package:riot/widgets/widgets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const rcc.NavigationDrawer(),
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
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
            backgroundColor: Colors.transparent,
            title: const Text(
              "Profile",
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
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              )
            ]),
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
                      20, MediaQuery.of(context).size.height * 0.15, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 8,
                        blurRadius: 10,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      )
                    ]),
                    child: Column(
                      children: <Widget>[
                        generateProfileElement(
                            title: "Username",
                            text: snapshot.data!.get('userName') ?? '',
                            mutable: true,
                            context: context),
                        generateProfileElement(
                            title: "Name",
                            text: snapshot.data!.get('name') ?? '',
                            mutable: true,
                            context: context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
