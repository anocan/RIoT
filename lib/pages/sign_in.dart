import 'package:flutter/material.dart';
import 'package:riot/pages/reset_password.dart';
import 'package:riot/widgets/widgets.dart';
import 'package:riot/pages/sign_up.dart';
import 'package:riot/themes/themes.dart' as themes;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    20, MediaQuery.of(context).size.height * 0.15, 20, 0),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/ras-ieee.png"),
                    const SizedBox(
                      height: 30,
                    ),
                    authTextField("Email", Icons.email_outlined, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    authTextField("Password", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 10,
                    ),
                    resetPasswordButton(),
                    authButton(context, 'Log In', () {
                      signInAccount(_emailTextController,
                          _passwordTextController, context);
                    }),
                    signUpButton(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  ],
                ))),
      ),
    );
  }

  Row signUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Create an account.",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUp()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row resetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ResetPassword()));
          },
          child: const Text(
            'Forget Password?',
            style: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
