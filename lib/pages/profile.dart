import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:riot/classes/classes.dart' as rcc;
import 'package:riot/widgets/widgets.dart';
import 'package:riot/classes/miscellaneous.dart';
import 'package:riot/classes/storage.dart';

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
                      20, MediaQuery.of(context).size.height * 0.2, 20, 0),
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
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top * 0.2,
                                  bottom: 0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: MediaQuery.of(context).size.height *
                                        0.115,
                                    child: Image.network(
                                      snapshot.data!.get('pp'),
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return CircleAvatar(
                                          radius: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.115,
                                          backgroundImage: const AssetImage(
                                              'assets/images/default-pp.jpg'),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            Positioned(
                                right: -4,
                                bottom: 24,
                                child: IconButton(
                                    iconSize: 48,
                                    onPressed: () async {
                                      final img = await selectImage();
                                      await StoreData().saveData(file: img);
                                    },
                                    icon: const Icon(Icons.add_a_photo_rounded),
                                    color: Colors.white)),
                          ],
                        ),
                        generateProfileElement(
                            title: "Username",
                            updateItem: "userName",
                            text: snapshot.data!.get('userName') ?? '',
                            mutable: false,
                            context: context),
                        generateProfileElement(
                            title: "Name",
                            updateItem: "name",
                            text: snapshot.data!.get('name') ?? '',
                            mutable: true,
                            context: context),
                        generateProfileElement(
                            title: "Phone Number",
                            updateItem: "phoneNumber",
                            text: snapshot.data!.get('phoneNumber') ?? '',
                            mutable: true,
                            context: context),
                        generateProfileElementPicker(
                          title: "Coffee or Tea?",
                          text: snapshot.data!.get("cot"),
                          updateItem: "cot",
                          items: ["Tea", "Coffee"],
                          mutable: true,
                          context: context,
                        ),
                        generateProfileElementPicker(
                            title: "Gender",
                            text: snapshot.data!.get("gender"),
                            updateItem: "gender",
                            items: ["Female", "Male", "Other"],
                            mutable: true,
                            context: context),
                        generateProfileElementPicker(
                            title: "Country",
                            text: snapshot.data!.get("country"),
                            updateItem: "country",
                            items: countries,
                            mutable: true,
                            context: context),
                        generateProfileElementPicker(
                            title: "Department",
                            text: snapshot.data!.get("department"),
                            updateItem: "department",
                            items: departments,
                            mutable: true,
                            context: context),
                        generateProfileElementDatePicker(
                            title: "Date of Birth",
                            text: snapshot.data!.get("dob"),
                            mutable: true,
                            updateItem: "dob",
                            context: context),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        )
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
