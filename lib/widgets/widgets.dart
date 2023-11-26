/// RIoT
/// Custom
/// Widgets
/// (rcw)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
          prefix: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Icon(
              icon,
              color: Colors.white70,
            ),
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
  String? userType,
  String? email,
  String? name,
  String? pp,
  String? phoneNumber,
  String? gender,
  String? dob,
  String? country,
  String? cot,
  String? department,
  Map<String, dynamic>? riotCard,
}) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);

  if (forSignUp) {
    // Initialize User
    final user = rcc.User(
        userType: "user",
        userName: userName!,
        email: email!,
        id: docUser.id,
        pp: "https://firebasestorage.googleapis.com/v0/b/riot-4n4n1f.appspot.com/o/serverData%2Fassets%2Fimages%2Fdefault-pp.jpg?alt=media&token=145c43cf-fa02-42be-8fbf-c626beaf1fd5");
    final json = user.toJson();
    await docUser.set(json);

    // Upload and set the default profile-picture
    /*
    ByteData byteData = await rootBundle.load('assets/images/default-pp.jpg');
    Uint8List img = byteData.buffer.asUint8List();
    await StoreData().saveData(file: img);*/

    return 1;
  }

  final docData = await docUser.get().then((value) {
    Map data = value.data() as Map;
    return data;
  });

  final user = rcc.User(
    id: docUser.id,
    userType: userType ?? docData['userType'],
    userName: userName ?? docData['userName'],
    email: email ?? docData['email'],
    name: name ?? docData['name'],
    pp: pp ?? docData['pp'],
    phoneNumber: phoneNumber ?? docData['phoneNumber'],
    gender: gender ?? docData['gender'],
    dob: dob ?? docData['dob'],
    country: country ?? docData['country'],
    cot: cot ?? docData['cot'],
    department: department ?? docData['department'],
    riotCard: riotCard ?? docData['riotCard'],
  );

  final json = user.toJson();

  await docUser.set(json);
}

/// Only one parameter at time should be passed when calling the function
bool regExpValidation({
  String? password,
  String? userName,
  String? name,
  String? phoneNumber,
}) {
  final passwordRegExp = RegExp(
      r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?!.*[^a-zA-Z0-9@#$*+!=])(.{6,18})$');
  final userNameRegExp = RegExp(r'^(?=.*[a-zA-Z])(?!.*[^a-zA-Z0-9])(.{6,8})$');
  final nameRegExp = RegExp(r'^(?!.*[^a-zA-Zıüöçğş])(.{0,12})$');
  final phoneNumberRegExp =
      RegExp(r'^\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})$');

  bool check = passwordRegExp.hasMatch(password ?? '%%%%%%%%%%%%%%%%%%%') ||
      userNameRegExp.hasMatch(userName ?? '%%%%%%%%%%%%%%%%%%%') ||
      nameRegExp.hasMatch(name ?? '%%%%%%%%%%%%%%%%%%%') ||
      phoneNumberRegExp.hasMatch(phoneNumber ?? '%%%%%%%%%%%%%%%%%%%');
  return check;
}

///
bool validateForm(
    {String? password, String? userName, String? name, String? phoneNumber}) {
  if (!regExpValidation(userName: userName) && userName != null) {
    throw rcc.LocalException(exception: "weak-username");
  }
  if (!regExpValidation(password: password) && password != null) {
    throw rcc.LocalException(exception: "weak-password");
  }
  if (!regExpValidation(name: name) && name != null) {
    throw rcc.LocalException(exception: "invalid-name");
  }
  if (!regExpValidation(phoneNumber: phoneNumber) && phoneNumber != null) {
    throw rcc.LocalException(exception: "invalid-gsm");
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
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
    }
  } on rcc.LocalException catch (e) {
    final text = notificationBar(text: errorGenerator(e.exception));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
    }
  }
}

Future<bool> isBanned() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final docData = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((value) {
    Map data = value.data() as Map;
    return data;
  });

  if (docData['userType'] == "banned") {
    return true;
  } else {
    return false;
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
        if (await isBanned()) {
          final text = notificationBar(
            text: 'You have been restricted. Please consult the admin.',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(text);
          }
        } else {
          if (context.mounted) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Home()));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Home()),
                (route) => false);
          }
        }
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
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
    }
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
    final text = notificationBar(text: errorGenerator(e.code));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(text);
    }
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
      return "Name must contain only letters (lower or upper case) in maximum 12 characters long.";
    case "invalid-gsm":
      return "Phone number must be in the following format: 5XXXXXXXXX";
    case "no-file-found":
      return "No file is found. Please try again.";
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
    required String updateItem,
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
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context!).size.width * 0.05,
                      fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: mutable
                    ? () {
                        showDialog(
                            context: context,
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
                                            switch (updateItem) {
                                              case "userName":
                                                validateForm(
                                                    userName:
                                                        textController.text);
                                                updateUser(
                                                    userName:
                                                        textController.text);
                                                break;
                                              case "name":
                                                validateForm(
                                                    name: textController.text);
                                                updateUser(
                                                    name: textController.text);
                                                break;
                                              case "phoneNumber":
                                                validateForm(
                                                    phoneNumber:
                                                        textController.text);
                                                updateUser(
                                                    phoneNumber:
                                                        textController.text);
                                                break;
                                            }
                                          } on rcc.LocalException catch (e) {
                                            final text = notificationBar(
                                                text: errorGenerator(
                                                    e.exception));
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(text);
                                          }
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
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
                  mutable ? Icons.settings_rounded : null,
                  color: Colors.white.withOpacity(1),
                ),
              ),
            ]),
        Divider(color: Colors.white.withAlpha(120), thickness: 3),
      ]),
    ],
  );
}

///
Wrap generateProfileElementPicker({
  required String title,
  required bool mutable,
  required List<String> items,
  required String updateItem,
  String? text,
  BuildContext? context,
}) {
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
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text ?? '',
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context!).size.width * 0.05,
                      fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: mutable
                    ? () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  rcc.ElementPicker(
                                    items: items,
                                    updateItem: updateItem,
                                  ), //
                                ],
                              ));
                            });
                      }
                    : () {},
                icon: Icon(
                  mutable ? Icons.settings_rounded : null,
                  color: Colors.white.withOpacity(1),
                ),
              ),
            ]),
        Divider(color: Colors.white.withAlpha(120), thickness: 3),
      ]),
    ],
  );
}

///
Center generatePicker(
    BuildContext context, List<String> items, String updateItem) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.72,
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(120),
              color: Colors.transparent),
          child: CupertinoPicker(
            diameterRatio: 1,
            backgroundColor: Colors.transparent,
            itemExtent: 64,
            onSelectedItemChanged: (index) {
              switch (updateItem) {
                case "cot":
                  updateUser(cot: items[index]);
                  break;
                case "gender":
                  updateUser(gender: items[index]);
                  break;
                case "department":
                  updateUser(department: items[index]);
                  break;
                case "country":
                  updateUser(country: items[index]);
                  break;
              }
            },
            children: items.map((e) => Center(child: Text(e))).toList(),
          ),
        ),
        CupertinoButton(
          onPressed: () {},
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}

///
Wrap generateProfileElementDatePicker(
    {required String title,
    required bool mutable,
    required String updateItem,
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
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context!).size.width * 0.05,
                      fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: mutable
                    ? () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const rcc.DatePicker();
                            });
                      }
                    : () {},
                icon: Icon(
                  mutable ? Icons.settings_rounded : null,
                  color: Colors.white.withOpacity(1),
                ),
              ),
            ]),
        Divider(color: Colors.white.withAlpha(120), thickness: 3),
      ]),
    ],
  );
}

///
Center generateDatePicker(BuildContext context) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45), color: Colors.white),
      width: MediaQuery.of(context).size.width * 0.72,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Expanded(
            child: CupertinoDatePicker(
              backgroundColor: Colors.transparent,
              mode: CupertinoDatePickerMode.date,
              dateOrder: DatePickerDateOrder.ymd,
              initialDateTime: DateTime(2000, 1, 1),
              maximumDate: DateTime.now(),
              minimumDate: DateTime(1960, 1, 1),
              onDateTimeChanged: (DateTime newDateTime) {
                updateUser(
                    dob: newDateTime.toString().split(' ')[0].toString());
              },
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Select",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
        ],
      ),
    ),
  );
}

///
Future<Uint8List> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  } else {
    throw rcc.LocalException(exception: "no-file-found");
  }
}

///
Future<Uint8List> selectImage() async {
  Uint8List image = await pickImage(ImageSource.gallery);
  return image;
}

///
Future updateAnotherUser({
  required String uID,
  String? userName,
  String? userType,
  String? email,
  String? name,
  String? pp,
  String? phoneNumber,
  String? gender,
  String? dob,
  String? country,
  String? cot,
  String? department,
  Map<String, dynamic>? riotCard,
}) async {
  final userId = uID;
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);

  final docData = await docUser.get().then((value) {
    Map data = value.data() as Map;
    return data;
  });

  final user = rcc.User(
    id: docUser.id,
    userType: userType ?? docData['userType'],
    userName: userName ?? docData['userName'],
    email: email ?? docData['email'],
    name: name ?? docData['name'],
    pp: pp ?? docData['pp'],
    phoneNumber: phoneNumber ?? docData['phoneNumber'],
    gender: gender ?? docData['gender'],
    dob: dob ?? docData['dob'],
    country: country ?? docData['country'],
    cot: cot ?? docData['cot'],
    department: department ?? docData['department'],
    riotCard: riotCard ?? docData['riotCard'],
  );

  final json = user.toJson();

  await docUser.set(json);
}

Future<void> removePrevRiotCardInstance(String idToCheck) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('riotCards')
      .where('id', isEqualTo: idToCheck)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Document with the specified ID exists
    var firstDocData = querySnapshot.docs[0].data() as Map<String, dynamic>?;

    if (firstDocData != null && firstDocData.containsKey('riotCardID')) {
      String? prevRiotCardID = firstDocData['riotCardID'] as String?;

      FirebaseFirestore.instance
          .collection('riotCards')
          .doc(prevRiotCardID)
          .delete();
    } else {
      //print("object");
    }
  }
}

Future<void> synchronizeRiotCards(
    String uID, String userName, String userType, dynamic updatedCard) async {
  final docRiotCard = FirebaseFirestore.instance
      .collection('riotCards')
      .doc(updatedCard['riotCardID']);

  await removePrevRiotCardInstance(uID);

  final riotCard = rcc.RiotCard(
    id: uID,
    inOrOut: updatedCard['inOrOut'],
    riotCardID: updatedCard['riotCardID'],
    riotCardStatus: updatedCard['riotCardStatus'],
    userType: updatedCard['userType'],
    userName: userName,
  );

  final json = riotCard.toJson();

  //final updatedRiotCardsMap = {'riotCardList': updatedRiotCardsList};

  await docRiotCard.set(json);
}
