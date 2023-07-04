import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/widgets/widgets.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ));
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ));
            },
          ),
          title: const Text(
            "Sign Up",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
              Color(0xff1f005c),
              Color(0xff5b0060),
              Color(0xff870160)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SingleChildScrollView(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  authTextField("Enter Username", Icons.person_outline, false,
                      _userNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  authTextField("Enter an Email Address", Icons.email_outlined,
                      false, _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  authTextField("Enter a Password", Icons.lock_outlined, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 25,
                  ),
                  authButton(context, 'Sign Up', () {
                    //FirebaseAuth.instance.signOut();
                    FirebaseAuth.instance.userChanges().listen((User? user) {
                      if (user == null) {
                        //print('User is currently signed out!');
                      } else {
                        () async {
                          //print('User is signed in!');
                          await FirebaseAuth.instance.signOut();
                        };
                      }
                    });
                    createAccount(
                      _emailTextController,
                      _passwordTextController,
                      _userNameTextController,
                      context,
                    );
                  }),
                ],
              ),
            ),
          )),
        ));
  }
}
