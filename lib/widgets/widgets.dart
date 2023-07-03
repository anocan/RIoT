import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/home.dart';
import 'package:riot/pages/sign_in.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    //color: Colors.white,
  );
}

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

SnackBar notificationBar(
    {required String text, String? label, Function? onTap}) {
  return SnackBar(
      action: label != null
          ? SnackBarAction(
              label: label ?? '',
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

Future createAccount(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    sendVerificationEmail();
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
    final text = notificationBar(text: fireBaseErrors(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

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
    final text = notificationBar(text: fireBaseErrors(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

Future sendVerificationEmail() async {
  final user = FirebaseAuth.instance.currentUser!;
  await user.sendEmailVerification();
}

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
    print(fireBaseErrors(e.code));
    final text = notificationBar(text: fireBaseErrors(e.code));
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(text);
  }
}

String fireBaseErrors(String error) {
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
      return "Given password is not strong enough.(Password should be at least 6 characters.)";
    case "wrong-password":
      return "Invalid password.";
    case "user-disabled":
      return "User corresponding to the given email address has been disabled, please contact us.";
    case "too-many-requests":
      return "Too many requests are send, please cool down and try again later.";
    default:
      return "Unexpected error, please contact us.";
  }
}
