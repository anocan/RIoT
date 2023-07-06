/// RIoT
/// Custom
/// Widgets
/// (rcw)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/home.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/classes/classes.dart' as rcc;
import 'dart:math' as math;

///
Color randomColor() {
  final color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  return color;
}

///
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    //color: Colors.white,
  );
}

///
TextField authTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  const inputRadius = 30.0;
  return TextField(
      controller: controller,
      obscureText: isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white.withOpacity(0.9)),
      decoration: InputDecoration(
          prefix: Icon(
            icon,
            color: Colors.white70,
          ),
          labelText: text,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(inputRadius),
              borderSide: const BorderSide(width: 0, style: BorderStyle.none))),
      keyboardType: isPasswordType
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress);
}

///
Container authButton(BuildContext context, String text, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}

///
SnackBar notificationBar(
    {required String text, String? label, Function? onTap}) {
  return SnackBar(
      action: label != null
          ? SnackBarAction(
              label: label,
              onPressed: () {
                onTap!() ?? () {};
              })
          : null,
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      backgroundColor: Colors.black87.withOpacity(0.3),
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            backgroundColor: Colors.transparent),
      ));
}

///
Future updateUser({
  bool forSignUp = false,
  String? userName,
  String? email,
  String? name,
  String? pp,
  String? phoneNumber,
  String? gender,
  String? dob,
  String? country,
  String? cot,
  String? favProfessor,
  String? department,
}) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);

  if (forSignUp) {
    final user = rcc.User(
      userName: userName!,
      email: email!,
    );
    final json = user.toJson();
    await docUser.set(json);
    return 1;
  }

  final docData = await docUser.get().then((value) {
    Map data = value.data() as Map;
    return data;
  });

  final user = rcc.User(
    id: docUser.id,
    userName: userName ?? docData['userName'],
    email: email ?? docData['email'],
    name: name ?? docData['name'],
    pp: pp ?? docData['pp'],
    phoneNumber: phoneNumber ?? docData['phoneNumber'],
    gender: gender ?? docData['gender'],
    dob: dob ?? docData['dob'],
    country: country ?? docData['country'],
    cot: cot ?? docData['cot'],
    favProfessor: favProfessor ?? docData['favProfessor'],
    department: department ?? docData['department'],
  );

  final json = user.toJson();

  await docUser.set(json);
}

/// Only one parameter at time should be passed when calling the function
bool regExpValidation({
  String password = '',
  String userName = '',
  String name = '',
  String pp = '',
  String phoneNumber = '',
  String gender = '',
  String dob = '',
  String country = '',
  String cot = '',
  String favProfessor = '',
  String department = '',
}) {
  final passwordRegExp = RegExp(
      r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?!.*[^a-zA-Z0-9@#$*+!=])(.{6,18})$');
  final userNameRegExp = RegExp(r'^(?=.*[a-zA-Z])(?!.*[^a-zA-Z0-9])(.{6,8})$');
  final nameRegExp = RegExp(r'^(?!.*[^a-zA-Z])(.{6,12})$');

  bool check = passwordRegExp.hasMatch(password) ||
      userNameRegExp.hasMatch(userName) ||
      nameRegExp.hasMatch(name);

  return check;
}

///
bool validateForm(
    {String password = 'null',
    String userName = 'null',
    String name = 'null'}) {
  if (!regExpValidation(userName: userName) && userName != 'null') {
    throw rcc.LocalException(exception: "weak-username");
  }
  if (!regExpValidation(password: password) && password != 'null') {
    throw rcc.LocalException(exception: "weak-password");
  }
  if (!regExpValidation(name: name) && name != 'null') {
    throw rcc.LocalException(exception: "invalid-name");
  }

  return true;
}

///
Future createAccount(
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController userNameController,
    BuildContext context) async {
  try {
    validateForm(
        password: passwordController.text, userName: userNameController.text);
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) => FirebaseAuth.instance.currentUser!
            .updateDisplayName(userNameController.text));
    sendVerificationEmail();
    await updateUser(
        forSignUp: true,
        userName: userNameController.text,
        email: emailController.text);
    final text =
        notificationBar(text: "Account created, please verify your email.");
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const SignIn()));
    }
  } on FirebaseAuthException catch (e) {
    final text = notificationBar(text: errorGenerator(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  } on rcc.LocalException catch (e) {
    final text = notificationBar(text: errorGenerator(e.exception));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

///
Future signInAccount(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    if (context.mounted) {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const Home()), (route) => false);
      } else {
        final text = notificationBar(
            label: 'Resend',
            text: 'Please verify your email.',
            onTap: () {
              sendVerificationEmail();
            });
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    }
  } on FirebaseAuthException catch (e) {
    final text = notificationBar(text: errorGenerator(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

///
Future sendVerificationEmail() async {
  final user = FirebaseAuth.instance.currentUser!;
  await user.sendEmailVerification();
}

///
Future sendResetEmail(
    TextEditingController controller, BuildContext context) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: controller.text);
    final text = notificationBar(text: "Reset email is sent.");
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
    }
  } on FirebaseAuthException catch (e) {
    print(errorGenerator(e.code));
    final text = notificationBar(text: errorGenerator(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

///
String errorGenerator(String error) {
  switch (error) {
    case "missing-email":
      return "Please enter an email address.";
    case "invalid-email":
      return "Please enter a valid email address.";
    case "user-not-found":
      return "No user has been found connected to this email.";
    case "email-already-in-use":
      return "Provided email is already in use.";
    case "weak-password":
      return "Password must contain at least one lower case, one upper case, one special character (@,#,\$,*,+,!,=) and one number in 6-18 long.";
    case "weak-username":
      return "Username must contain at least one character without special characters in 6-8 long.";
    case "wrong-password":
      return "Invalid password.";
    case "user-disabled":
      return "User corresponding to the given email address has been disabled, please contact us.";
    case "too-many-requests":
      return "Too many requests are send, please cool down and try again later.";
    case "network-request-failed":
      return "Network request failed, check your connection.";
    case "invalid-name":
      return "Name must contain only letters (lower or upper case) in 6-12 long.";
    default:
      return "Unexpected error, please contact us.";
  }
}

///
Wrap generateMenuItem(
    {required BuildContext context,
    required String text,
    required IconData icon,
    required Function onTap,
    bool? isLogOut}) {
  return Wrap(children: [
    ListTile(
      leading: Icon(
        icon,
        color: isLogOut != null ? Colors.black : Colors.white,
        size: 32,
      ),
      title: Text(
        text,
        style: TextStyle(
            color: isLogOut != null ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24),
      ),
      onTap: () {
        onTap();
      },
    ),
    Divider(
      color: Colors.white.withAlpha(120),
      thickness: 3,
    ),
  ]);
}

///
Wrap generateProfileElement(
    {required String title,
    required bool mutable,
    String? text,
    BuildContext? context}) {
  return Wrap(
    children: [
      Row(
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          )
        ],
      ),
      Wrap(children: [
        Row(children: [
          Text(
            text ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(flex: 1),
          IconButton(
            onPressed: mutable
                ? () {
                    showDialog(
                        context: context!,
                        builder: (BuildContext context) {
                          var textController = TextEditingController();
                          return AlertDialog(
                            content: Stack(
                              children: <Widget>[
                                TextField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                    onPressed: () {
                                      try {
                                        validateForm(name: textController.text);
                                        updateUser(name: textController.text);
                                      } on rcc.LocalException catch (e) {
                                        final text = notificationBar(
                                            text: errorGenerator(e.exception));
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(text);
                                      }
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.save_outlined),
                                  )),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                : () {},
            icon: Icon(
              mutable ? Icons.settings_rounded : Icons.do_disturb,
              color: Colors.white.withOpacity(1),
            ),
          ),
        ]),
        Divider(color: Colors.white.withAlpha(120), thickness: 3),
      ]),
    ],
  );
}
