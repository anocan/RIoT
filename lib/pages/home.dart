import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/themes/themes.dart' as themes;
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
    return Scaffold(
      drawer: const NavigationDrawer(),
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
          themes.color1, //Color(0xff1f005c),
          themes.color2, //Color(0xff5b0060),
          themes.color3, //Color(0xff870160),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(),
      ),
    );
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
          onTap: () {},
          child: Container(
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
                  "Hello ${FirebaseAuth.instance.currentUser!.displayName},",
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
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
