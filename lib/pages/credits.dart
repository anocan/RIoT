import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:riot/classes/classes.dart' as rcc;
import 'package:url_launcher/url_launcher.dart';

class Credits extends StatefulWidget {
  const Credits({super.key});

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
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
                  "Credits",
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
                MediaQuery.of(context).size.width * 0.0,
                MediaQuery.of(context).size.height * 0.0,
                MediaQuery.of(context).size.width * 0.00,
                0),
            child: Container(
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
                        Text(
                          "This app and project RIoT are realized by Anıl Budak with special thanks to Deniz Petek, Volkan Taştan, and Kayra Toprak Say.",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Center(
                          child: InkWell(
                              child: const Text(
                                'Linkedin Page (linkedin/in/anilbudak)',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () => launchUrl(Uri.parse(
                                  'https://www.linkedin.com/in/anilbudak/'))),
                        ),
                        Center(
                          child: InkWell(
                              child: const Text(
                                'Github Page (https://github.com/anocan)',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () => launchUrl(
                                  Uri.parse('https://github.com/anocan'))),
                        ),
                        Image.asset(
                          "assets/gifs/nyan-cat-nyan.gif",
                          height: 125.0,
                          width: 125.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
