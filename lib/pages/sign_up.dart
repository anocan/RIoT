import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/widgets/widgets.dart';
import 'package:riot/themes/themes.dart' as themes;

Row pdpaButton(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () {
          String privacyPolicy = '''\n1. Information We Collect:\n
   - We may collect personal information, including but not limited to names, contact details, and user preferences.
   - Information may be collected through the RIoT project platform or other communication channels.\n
2. How We Use Your Information:\n
   - Personal information is used for the purpose of improving and providing services related to the RIoT project.
   - Information may be used for communication, project updates, and support.

3. Information Sharing:\n
   - We do not sell, trade, or otherwise transfer your personal information to third parties without your consent.\n
4. Data Security:\n
   - We implement security measures to protect your personal information.
   - However, we cannot guarantee the security of information transmitted over the internet.

5. Your Rights:\n
   - You have the right to access, correct, or delete your personal information.
   - Contact us if you wish to exercise these rights or have questions about your data.

6. Changes to Privacy Policy:\n
   - This Privacy Policy may be updated to reflect changes in our practices.
   - Check this page periodically for updates.
\n''';
          String termsOfService = '''

1. Acceptance of Terms:\n
   - By using the RIoT project platform, you agree to abide by these Terms of Service.

2. User Conduct:\n
   - Users are responsible for their actions and content posted on the RIoT platform.
   - Users must comply with applicable laws and regulations.

3. Intellectual Property:\n
   - The RIoT project and its content are protected by intellectual property laws.
   - Users may not use project materials without permission.

4. Termination:\n
   - We reserve the right to terminate user accounts for violations of these Terms of Service.

5. Limitation of Liability:\n
   - We are not liable for any damages or losses resulting from the use of the RIoT project platform.

6. Governing Law:\n
   - These Terms of Service are governed by and construed in accordance with the laws of KVKK (Personal Data Protection Law).

7. Changes to Terms:\n
   - We reserve the right to modify these Terms of Service at any time.
   - Continued use of the RIoT platform constitutes acceptance of the modified terms.''';

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '\nPrivacy Policy',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: privacyPolicy),
                            ],
                          ),
                        ),
                        const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: termsOfService),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: const Text(
          '*By signing up, you accept our terms, conditions\nand personal data policy.',
          style: TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}

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
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
              themes.color1,
              themes.color2,
              themes.color3,
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
                  pdpaButton(context),
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
