/// RIoT
/// Custom
/// Classes
/// (rcc)
library;

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:riot/pages/admin_panel.dart';
import 'package:riot/pages/credits.dart';
import 'package:riot/pages/home.dart';
import 'package:riot/pages/profile.dart';
import 'package:riot/pages/report.dart';
import 'package:riot/pages/sign_in.dart';
import 'package:riot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riot/themes/themes.dart' as themes;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  /// User types are superadmin, admin, banned, user, deleted
  String id;
  final String userType;
  final String userName;
  final String email;
  final String name;
  late final String pp; // Profile Picture
  final String phoneNumber;
  final String gender;
  final String dob; // Date of Birth
  final String country;
  final String cot; // Coffee or Tea?
  final String department;
  final Map<String, dynamic> riotCard;

  User({
    required this.userName,
    required this.email,
    required this.userType,
    this.id = '',
    this.name = '',
    this.pp = '',
    this.phoneNumber = '',
    this.gender = '',
    this.dob = '',
    this.country = '',
    this.cot = '',
    this.department = '',
    this.riotCard = const {
      'inOrOut': 'out',
      'riotCardID': '',
      'riotCardStatus': 'inactive',
    },
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userType': userType,
        'userName': userName,
        'email': email,
        'name': name,
        'pp': pp,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dob': dob,
        'country': country,
        'cot': cot,
        'department': department,
        'riotCard': riotCard,
      };
}

class RiotCard {
  String id;
  final String inOrOut;
  final String riotCardID;
  final String riotCardStatus;
  final String userName;
  final String userType;

  RiotCard({
    this.id = '',
    this.inOrOut = '',
    this.riotCardID = '',
    this.riotCardStatus = '',
    this.userName = '',
    this.userType = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'inOrOut': inOrOut,
        'riotCardID': riotCardID,
        'riotCardStatus': riotCardStatus,
        'userName': userName,
        'userType': userType
      };
}

class LocalException {
  String exception;

  LocalException({required this.exception}) {
    exception = _parseString(exception);
  }

  String _parseString(String exception) {
    return exception.substring(0);
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
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
          onTap: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Profile()));
          },
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      //CircularProgressIndicator(),
                    ],
                  );
                }
                Image.network(
                  snapshot.data!.get('pp'),
                  errorBuilder: (context, error, stackTrace) {
                    setState(() {});
                    throw ("error");
                  },
                );

                return Container(
                  padding: EdgeInsets.only(
                      top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
                  child: Column(
                    // BUGGED
                    children: [
                      CircleAvatar(
                        foregroundImage: NetworkImage(snapshot.data!.get('pp')),
                        onForegroundImageError: (exception, stackTrace) {},
                        radius: MediaQuery.of(context).size.height * 0.09,
                        backgroundImage:
                            const AssetImage("assets/images/default-pp.jpg"),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Hello, ${snapshot.data!.get('userName') ?? ''}",
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
        ),
      );

  Future<String?> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  Widget buildMenuItems(BuildContext context) {
    return FutureBuilder<String?>(
        future: getPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while data is being fetched
            return const SizedBox(
              height: 0,
            );
          } else if (snapshot.hasError) {
            // Handle the error
            return Text('Error: ${snapshot.error}');
          } else {
            final String? userType = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                runSpacing: 8,
                children: [
                  userType == "admin" || userType == "superadmin"
                      ? generateMenuItem(
                          context: context,
                          text: "Admin Panel",
                          icon: Icons.admin_panel_settings_rounded,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const AdminPanel()));
                          })
                      : const Wrap(),
                  generateMenuItem(
                      context: context,
                      text: "Home",
                      icon: Icons.home_rounded,
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const Home()));
                      }),
                  generateMenuItem(
                      context: context,
                      text: "Report Bug&Feature",
                      icon: Icons.bug_report_rounded,
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const Report()));
                      }),
                  generateMenuItem(
                      context: context,
                      text: "Credits",
                      icon: Icons.verified_rounded,
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const Credits()));
                      }),
                  const SizedBox(height: 120),
                  generateMenuItem(
                      context: context,
                      text: "Log Out",
                      icon: Icons.exit_to_app_rounded,
                      onTap: () {
                        try {
                          FirebaseAuth.instance.signOut().then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignIn()));
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignIn()),
                                (route) => false);
                          });
                        } on PlatformException catch (e) {
                          if (e.code == 'firebase_auth/keychain-error') {
                            //print('Error details: ${e.details}');

                            // Print NSError.userInfo dictionary
                            if (e.details != null &&
                                e.details['NSErrorUserInfo'] != null) {
                              //print('UserInfo dictionary:');
                              //print(e.details['NSErrorUserInfo']);
                            }
                          }
                        }
                      },
                      isLogOut: true),
                  const Text("v1.0.2"),
                ],
              ),
            );
          }
        });
  }
}

class ElementPicker extends StatefulWidget {
  final List<String> items;
  final String updateItem;
  const ElementPicker(
      {super.key, required this.items, required this.updateItem});

  @override
  State<ElementPicker> createState() => _ElementPickerState();
}

class _ElementPickerState extends State<ElementPicker> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
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
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: widget.items
                  .map((e) => Center(
                          child: Text(
                        e,
                        textAlign: TextAlign.center,
                      )))
                  .toList(),
            ),
          ),
          CupertinoButton(
            onPressed: () {
              switch (widget.updateItem) {
                case "cot":
                  updateUser(cot: widget.items[selectedIndex]);
                  break;
                case "gender":
                  updateUser(gender: widget.items[selectedIndex]);
                  break;
                case "department":
                  updateUser(department: widget.items[selectedIndex]);
                  break;
                case "country":
                  updateUser(country: widget.items[selectedIndex]);
                  break;
              }
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              "Select",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  var selectedDate = DateTime(2000, 1, 1);
  @override
  Widget build(BuildContext context) {
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
                onDateTimeChanged: (DateTime time) {
                  setState(() {
                    selectedDate = time;
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                updateUser(
                    dob: selectedDate.toString().split(' ')[0].toString());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
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
}

class CustomDropdownMenu extends StatefulWidget {
  final List<String> items;
  final Function onCallback;
  const CustomDropdownMenu(
      {super.key, required this.items, required this.onCallback});

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(190),
      ),
      menuStyle: const MenuStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.white)),
      initialSelection: widget.items.first,
      onSelected: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          widget.onCallback(dropdownValue);
        });
      },
      dropdownMenuEntries:
          widget.items.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}

class ReportMenu extends StatefulWidget {
  const ReportMenu({super.key});

  @override
  State<ReportMenu> createState() => _ReportMenuState();
}

class _ReportMenuState extends State<ReportMenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController reportText = TextEditingController();
  String selectedValue = "Bug";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: reportText,
            maxLines: (MediaQuery.of(context).size.height * 0.01).round(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withAlpha(190),
              border: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 3, color: Colors.white.withAlpha(120))),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 3, color: Colors.white.withAlpha(120))),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 3, color: Colors.white.withAlpha(60))),
              hintText: 'Convey your thoughts.',
              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomDropdownMenu(
                items: const ["Bug", "Feature"],
                onCallback: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.white.withAlpha(240)),
                  ),
                  onPressed: () async {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      final deviceInfoPlugin = DeviceInfoPlugin();
                      final deviceInfo = await deviceInfoPlugin.deviceInfo;
                      final allInfo = deviceInfo.data;

                      await FirebaseFirestore.instance
                          .collection("reports")
                          .add({
                        "uid": FirebaseAuth.instance.currentUser!.uid,
                        "reportType": selectedValue,
                        "deviceInfo": allInfo,
                        "message": reportText.text,
                        "status": "Active",
                        "date": DateTime.now().toString(),
                      });
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const Home()),
                            (route) => false);
                        final text = notificationBar(
                          text: "Your report has been succesfuly sent.",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(text);
                      }
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeElement extends StatefulWidget {
  final String labData;
  final String description;
  final Icon icon;
  const HomeElement({
    super.key,
    required this.labData,
    required this.description,
    required this.icon,
  });

  @override
  State<HomeElement> createState() => _HomeElementState();
}

class _HomeElementState extends State<HomeElement> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          deviceWidth * 0.05, 0, deviceWidth * 0.05, deviceHeight * 0.04),
      child: Container(
        padding: EdgeInsets.fromLTRB(deviceWidth * 0.02, deviceHeight * 0.04,
            deviceWidth * 0.02, deviceHeight * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(deviceHeight * 0.01),
          border: Border.all(width: deviceWidth * 0.01, color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.description,
              style: TextStyle(
                  fontSize: deviceWidth * 0.035, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                widget.icon,
                SizedBox(
                  width: deviceWidth * 0.02,
                ),
                Text(
                  widget.labData,
                  style: TextStyle(
                      fontSize: deviceWidth * 0.08,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Future<Map> getUserData() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);
  final docSnapshot = await docUser.get();
  final data = docSnapshot.data() as Map;
  return data;
}

class AdminPanelPicker extends StatefulWidget {
  final List<String> items;
  final String uID;
  final String updateElement;
  final String initialItem;
  final Function(String data, String dataType) updateParent;
  final Map<String, dynamic> updateItem;
  const AdminPanelPicker(
      {super.key,
      required this.items,
      required this.uID,
      required this.updateElement,
      required this.initialItem,
      required this.updateParent,
      required this.updateItem});

  @override
  State<AdminPanelPicker> createState() => _AdminPanelPickerState();
}

class _AdminPanelPickerState extends State<AdminPanelPicker> {
  List<String> riotCardIndexesInOrOut = [
    'in',
    'out',
  ];
  List<String> riotCardIndexesCardStatus = [
    'active',
    'inactive',
    'disabled',
  ];
  late FixedExtentScrollController _scrollController;

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    int initialItemIndex = 0;
    switch (widget.updateElement) {
      case 'inOrOut':
        initialItemIndex = riotCardIndexesInOrOut.indexOf(widget.initialItem);
        break;
      case 'riotCardStatus':
        initialItemIndex =
            riotCardIndexesCardStatus.indexOf(widget.initialItem);
        break;
    }

    _scrollController =
        FixedExtentScrollController(initialItem: initialItemIndex);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.36,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                color: Colors.transparent),
            child: CupertinoPicker(
              scrollController: _scrollController,
              diameterRatio: 1,
              backgroundColor: Colors.transparent,
              itemExtent: 64,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedIndex = index;
                  widget.updateParent(
                      widget.items[selectedIndex], widget.updateElement);
                });
              },
              children: List.generate(
                widget.items.length,
                (index) => Center(
                  child: Text(
                    widget.items[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          index == initialItemIndex ? Colors.red : Colors.black,
                      fontWeight: index == initialItemIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUsers extends StatefulWidget {
  final Stream stream;
  final String description;
  final Icon icon;
  const AdminUsers({
    super.key,
    required this.stream,
    required this.description,
    required this.icon,
  });

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    Map currentUser = {};
    getUserData().then((value) {
      currentUser = value;
    });
    return Padding(
        padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.02, 0, deviceWidth * 0.02, deviceHeight * 0.02),
        child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              //final labData = snapshot.data!.get(widget.labData);
              return Container(
                  padding: EdgeInsets.fromLTRB(
                      deviceWidth * 0.0,
                      deviceHeight * 0.0,
                      deviceWidth * 0.0,
                      deviceHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                    border: Border.all(
                        width: deviceWidth * 0.01, color: Colors.white),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Text(
                            "Users",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32),
                          ),
                        ),
                        SizedBox(
                          height: deviceHeight * 0.4,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var doc = snapshot.data!.docs;
                                return Container(
                                  padding: EdgeInsets.fromLTRB(
                                      deviceWidth * 0.0,
                                      deviceHeight * 0.0,
                                      deviceWidth * 0.0,
                                      deviceHeight * 0.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(
                                        deviceHeight * 0.01),
                                    border: Border.all(
                                        width: deviceWidth * 0.01,
                                        color: Colors.white),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          widget.icon,
                                          TextButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text(
                                                          "User Details",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "userName: ${doc[index]['userName']}\n"),
                                                            Text(
                                                                "id: ${doc[index]['id']}\n"),
                                                            Text(
                                                                "userType: ${doc[index]['userType']}\n"),
                                                            Text(
                                                                "email: ${doc[index]['email']}\n"),
                                                            Text(
                                                                "name: ${doc[index]['name']}\n"),
                                                            Text(
                                                                "phoneNumber: ${doc[index]['phoneNumber']}\n"),
                                                            Text(
                                                                "dob: ${doc[index]['dob']}\n"),
                                                            Text(
                                                                "gender: ${doc[index]['gender']}\n"),
                                                            Text(
                                                                "pp: ${doc[index]['pp']}\n"),
                                                            Text(
                                                                "riotCard: ${doc[index]['riotCard']}\n"),
                                                            Text(
                                                                "department: ${doc[index]['department']}\n"),
                                                            Text(
                                                                "country: ${doc[index]['country']}\n"),
                                                            Text(
                                                                "cot: ${doc[index]['cot']}\n"),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text(
                                                doc[index]['userName'],
                                                style: TextStyle(
                                                    decoration: doc[index]
                                                                ['userType'] ==
                                                            "deleted"
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                    fontSize:
                                                        deviceWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                    color: doc[index]
                                                                    ['riotCard']
                                                                ['inOrOut'] ==
                                                            "in"
                                                        ? Colors.green
                                                        : Colors.black),
                                              )),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text(
                                                          "RIoT Card Details",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: Column(
                                                          children: [
                                                            Text(
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['userName'],
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16),
                                                            ),
                                                            const SizedBox(
                                                              height: 24,
                                                            ),
                                                            AdminRiotCardController(
                                                              document: snapshot
                                                                  .data!.docs,
                                                              index: index,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              icon: const Icon(
                                                  Icons.credit_card)),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      if (currentUser[
                                                              'userType'] !=
                                                          'superadmin') {
                                                        return const AlertDialog(
                                                            scrollable: true,
                                                            title: Text(
                                                              "User Status can only be modified by superadmin.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            content: Column());
                                                      } else if (currentUser[
                                                              'userType'] ==
                                                          'superadmin') {
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: const Text(
                                                            "Change User Status",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          content: Column(
                                                            children: [
                                                              Text(
                                                                snapshot.data!
                                                                            .docs[
                                                                        index][
                                                                    'userName'],
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              const SizedBox(
                                                                height: 24,
                                                              ),
                                                              AdminUpdateUserType(
                                                                uID: doc[index]
                                                                    ['id'],
                                                                items: const [
                                                                  'user',
                                                                  'banned',
                                                                  'admin'
                                                                ],
                                                                initialItem: doc[
                                                                        index][
                                                                    'userType'],
                                                                riotCardID: doc[
                                                                            index]
                                                                        [
                                                                        'riotCard']
                                                                    [
                                                                    'riotCardID'],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                      return const Wrap();
                                                    });
                                              },
                                              icon: const Icon(
                                                  Icons.account_tree_outlined)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ));
            }));
  }
}

class AdminRiotCardController extends StatefulWidget {
  final dynamic document;
  final int index;
  const AdminRiotCardController({
    super.key,
    required this.document,
    required this.index,
  });

  @override
  State<AdminRiotCardController> createState() =>
      _AdminRiotCardControllerState();
}

class _AdminRiotCardControllerState extends State<AdminRiotCardController> {
  late TextEditingController _textController;
  late String riotCardIDState;
  late String inOrOutState;
  late String riotCardStatusState;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: "");
    inOrOutState = widget.document[widget.index]['riotCard']['inOrOut'];
    riotCardStatusState =
        widget.document[widget.index]['riotCard']['riotCardStatus'];
    riotCardIDState = widget.document[widget.index]['riotCard']['riotCardID'];
  }

  void updateController(String data, String dataType) {
    setState(() {
      switch (dataType) {
        case "inOrOut":
          inOrOutState = data;
          //print(inOrOutState);
          break;
        case "riotCardStatus":
          riotCardStatusState = data;
          //print(riotCardStatusState);
          break;
        case "riotCardID":
          riotCardIDState = data;
          //print(riotCardIDState);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onChanged: (value) {
            updateController(_textController.text, "riotCardID");
          },
          controller: _textController,
          maxLength: 8,
          decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Text(
                "riotCardID: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.ideographic),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText:
                  "${widget.document[widget.index]['riotCard']['riotCardID']}"),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "inOrOut:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            AdminPanelPicker(
              uID: widget.document[widget.index]['id'],
              updateElement: 'inOrOut',
              initialItem: widget.document[widget.index]['riotCard']['inOrOut'],
              items: const ['in', 'out'],
              updateItem: widget.document[widget.index]['riotCard'],
              updateParent: updateController,
            )
          ],
        ),
        Row(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.01,
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "riotCardStatus:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            AdminPanelPicker(
              uID: widget.document[widget.index]['id'],
              updateElement: 'riotCardStatus',
              items: const [
                'active',
                'inactive',
                'disabled',
              ],
              initialItem: widget.document[widget.index]['riotCard']
                  ['riotCardStatus'],
              updateItem: widget.document[widget.index]['riotCard'],
              updateParent: updateController,
            )
          ],
        ),
        GestureDetector(
          onTap: () async {
            var updatedCard = widget.document[widget.index]['riotCard'];
            updatedCard['riotCardID'] = riotCardIDState;
            updatedCard['riotCardStatus'] = riotCardStatusState;
            updatedCard['userType'] = widget.document[widget.index]['userType'];
            updatedCard['inOrOut'] = inOrOutState;
            if (widget.document[widget.index]['riotCard']['riotCardID'] == "") {
              final text = notificationBar(
                text: "No riotCard found in the database to be updated.",
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(text);
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              return;
            }
            await synchronizeRiotCards(
                    widget.document[widget.index]['id'],
                    widget.document[widget.index]['userName'],
                    widget.document[widget.index]['userType'],
                    updatedCard)
                .onError((error, stackTrace) {});

            updatedCard.remove('userType');
            await updateAnotherUser(
                    uID: widget.document[widget.index]['id'],
                    riotCard: updatedCard)
                .then((value) {
              final text = notificationBar(
                text: "RIoT card successfuly modified.",
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(text);
              }
            }).then((value) async {
              await FirebaseFirestore.instance
                  .collection('labData')
                  .doc('lab-metadata')
                  .update({'updateStatus': 'outOfDate'});
            }).then((value) =>
                    Navigator.of(context).popUntil((route) => route.isFirst));
          },
          child: Container(
              padding: const EdgeInsets.all(8),
              child: const Center(
                child: Text(
                  "Save",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.purple),
                ),
              )),
        ),
      ],
    );
  }
}

class AdminUpdateUserType extends StatefulWidget {
  final List<String> items;
  final String uID;
  final String initialItem;
  final String riotCardID;
  const AdminUpdateUserType({
    super.key,
    required this.items,
    required this.uID,
    required this.initialItem,
    this.riotCardID = "",
  });

  @override
  State<AdminUpdateUserType> createState() => _AdminUpdateUserTypeState();
}

class _AdminUpdateUserTypeState extends State<AdminUpdateUserType> {
  int initialItemIndex = 0;
  late FixedExtentScrollController _scrollController;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //FirebaseFirestore.instance.collection("riotCard")
    initialItemIndex = widget.items.indexOf(widget.initialItem);
    _scrollController =
        FixedExtentScrollController(initialItem: initialItemIndex);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.36,
            height: MediaQuery.of(context).size.height * 0.12,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                color: Colors.transparent),
            child: Column(
              children: [
                CupertinoPicker(
                  scrollController: _scrollController,
                  diameterRatio: 1,
                  backgroundColor: Colors.transparent,
                  itemExtent: 64,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  children: List.generate(
                    widget.items.length,
                    (index) => Center(
                      child: Text(
                        widget.items[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: index == initialItemIndex
                              ? Colors.red
                              : Colors.black,
                          fontWeight: index == initialItemIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            child: const Text(
              "Apply",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.purple),
            ),
            onPressed: () {
              if (widget.initialItem == "deleted") {
                final text = notificationBar(
                    text:
                        "User account is deleted, user type cannot be modified.");
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(text);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } else {
                if (context.mounted) {
                  try {
                    final CollectionReference collectionReference =
                        FirebaseFirestore.instance.collection("riotCards");
                    collectionReference.doc(widget.riotCardID).update({
                      "userType": widget.items[selectedIndex]
                    }).whenComplete(() async {
                      //print("Completed");
                    }).catchError((e) {
                      //print(e);
                    });
                  } catch (e) {
                    //print(e);
                  }

                  updateAnotherUser(
                          uID: widget.uID,
                          userType: widget.items[selectedIndex])
                      .then((value) => Navigator.of(context)
                          .popUntil((route) => route.isFirst));
                  final text = notificationBar(
                      text: "User type is successfuly modified.");
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(text);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class DeleteAccountButton extends StatefulWidget {
  const DeleteAccountButton({super.key});

  @override
  State<DeleteAccountButton> createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends State<DeleteAccountButton> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showDeleteAccountDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Set button color to red
        minimumSize: const Size(double.infinity, 50), // Make the button wide
      ),
      child: const Text(
        'Delete Account',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final TextEditingController passwordTextController =
        TextEditingController();
    final TextEditingController emailTextController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text(
            'Enter Credentials',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              authTextField(
                  "Email", Icons.email_outlined, false, emailTextController),
              const SizedBox(
                height: 20,
              ),
              authTextField(
                  "Password", Icons.lock_outline, true, passwordTextController),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "*Your account will be deleted and your RIoT card will be deactivated from the RIoT system."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: emailTextController.text,
                      password: passwordTextController.text);

                  _deleteAccount(credential);
                  //Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String extractErrorMessage(String errorMessage) {
    // Find the first occurrence of '[' and ']'
    int startIndex = errorMessage.indexOf('[');
    int endIndex = errorMessage.indexOf(']');

    // Check if both '[' and ']' are present and '[' comes before ']'
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      // Extract the substring excluding the square bracket part
      return errorMessage.substring(endIndex + 1).trim();
    } else {
      // Return the original message if square brackets are not found
      return errorMessage;
    }
  }

  void _deleteAccount(AuthCredential credential) async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);

      // User is succesfuly reauthenticate

      updateUser(userType: 'deleted').then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SignIn()));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignIn()),
            (route) => false);

        final text = notificationBar(
          text: 'Your account has been successfully deleted :(',
        );
        ScaffoldMessenger.of(context).showSnackBar(text);
      }).then((_) {
        getUserData().then((value) {
          final riotCardID = value['riotCard']['riotCardID'];
          final userID = value['id'];
          if (riotCardID != "") {
            FirebaseFirestore.instance
                .collection("riotCards")
                .doc(riotCardID)
                .update({"userType": "deleted"});
          }
          FirebaseFirestore.instance.collection("users").doc(userID).update({
            "riotCard": {
              "inOrOut": "out",
              "riotCardID": riotCardID,
              "riotCardStatus": "inactive",
            }
          });
        });
      }).then((value) {
        FirebaseAuth.instance.currentUser!.delete();
      });
    } on FirebaseAuthException catch (e) {
      final text = notificationBar(
        text: extractErrorMessage(e.toString()),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(text);
      }

      // Handle reauthentication errors
      //print("Reauthentication failed: $e");
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class AdminDoorStatus extends StatefulWidget {
  final Stream stream;
  const AdminDoorStatus({
    super.key,
    required this.stream,
  });

  @override
  State<AdminDoorStatus> createState() => _AdminDoorStatusState();
}

class _AdminDoorStatusState extends State<AdminDoorStatus> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.02, 0, deviceWidth * 0.02, deviceHeight * 0.02),
        child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final doorData = snapshot.data!.get("labDoor");

              return Container(
                  padding: EdgeInsets.fromLTRB(
                      deviceWidth * 0.0,
                      deviceHeight * 0.0,
                      deviceWidth * 0.0,
                      deviceHeight * 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                    border: Border.all(
                        width: deviceWidth * 0.01, color: Colors.white),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Text(
                            "RIoT Door",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              deviceWidth * 0.0,
                              deviceHeight * 0.0,
                              deviceWidth * 0.0,
                              deviceHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.circular(deviceHeight * 0.01),
                            border: Border.all(
                                width: deviceWidth * 0.01, color: Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showVerifiyAccountDialog(
                                        context, "locked");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    backgroundColor: doorData == "locked"
                                        ? Colors.red
                                        : Colors
                                            .grey, // Set button color to red
                                  ),
                                  child: const Text(
                                    'Lock Door',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showVerifiyAccountDialog(
                                        context, "unlocked");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    backgroundColor: doorData == "unlocked"
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  child: const Text(
                                    'Unlock Door',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showVerifiyAccountDialog(
                                        context, "secured");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    backgroundColor: doorData == "secured"
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  child: const Text(
                                    'Secure Door',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            }));
  }

  Future<void> _showVerifiyAccountDialog(
      BuildContext context, String doorStatus) async {
    final TextEditingController passwordTextController =
        TextEditingController();
    final TextEditingController emailTextController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text(
            'Enter Credentials',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              authTextField(
                  "Email", Icons.email_outlined, false, emailTextController),
              const SizedBox(
                height: 20,
              ),
              authTextField(
                  "Password", Icons.lock_outline, true, passwordTextController),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "*Your credentials are needed to ensure your account is authorized."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: emailTextController.text,
                      password: passwordTextController.text);

                  _changeDoorStatus(credential, doorStatus);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeDoorStatus(AuthCredential credential, String doorStatus) async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);

      CollectionReference labData =
          FirebaseFirestore.instance.collection('labData');
      await labData.doc('lab-data').update({
        'labDoor': doorStatus,
      }).then((value) {
        Navigator.of(context).popUntil((route) => route.isFirst);

        final text = notificationBar(
          text: 'RIoT door is successfuly $doorStatus.',
        );
        ScaffoldMessenger.of(context).showSnackBar(text);
      });
    } on FirebaseAuthException catch (e) {
      final text = notificationBar(
        text: extractErrorMessage(e.toString()),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    }
  }

  String extractErrorMessage(String errorMessage) {
    // Find the first occurrence of '[' and ']'
    int startIndex = errorMessage.indexOf('[');
    int endIndex = errorMessage.indexOf(']');

    // Check if both '[' and ']' are present and '[' comes before ']'
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      // Extract the substring excluding the square bracket part
      return errorMessage.substring(endIndex + 1).trim();
    } else {
      // Return the original message if square brackets are not found
      return errorMessage;
    }
  }
}

class AdminTools extends StatefulWidget {
  final Stream stream;
  const AdminTools({
    super.key,
    required this.stream,
  });

  @override
  State<AdminTools> createState() => _AdminToolsState();
}

class _AdminToolsState extends State<AdminTools> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.02, 0, deviceWidth * 0.02, deviceHeight * 0.02),
        child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              return Container(
                  padding: EdgeInsets.fromLTRB(
                      deviceWidth * 0.0,
                      deviceHeight * 0.0,
                      deviceWidth * 0.0,
                      deviceHeight * 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                    border: Border.all(
                        width: deviceWidth * 0.01, color: Colors.white),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Text(
                            "Admin Tools",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              deviceWidth * 0.0,
                              deviceHeight * 0.0,
                              deviceWidth * 0.0,
                              deviceHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.circular(deviceHeight * 0.01),
                            border: Border.all(
                                width: deviceWidth * 0.01, color: Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showAddJunkDataDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const BeveledRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      backgroundColor: Colors
                                          .blue, // Set button color to red
                                    ),
                                    child: const Text(
                                      'Add Junk RIoT Card Data',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: deviceWidth * 0.01,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showRemoveJunkDataDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const BeveledRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      backgroundColor: Colors
                                          .blue, // Set button color to red
                                    ),
                                    child: const Text(
                                      'Remove Junk RIoT Card Data',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: deviceWidth * 0.01,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showAddJunkUserDataDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const BeveledRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      backgroundColor: Colors
                                          .blue, // Set button color to red
                                    ),
                                    child: const Text(
                                      'Add & Remove Junk User Data',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            }));
  }

  Future<void> _showAddJunkUserDataDialog(BuildContext context) async {
    int selectedCount = 1; // Initialize selected count
    String selectedInOut = 'in'; // Initialize selected "in" or "out"
    String selectedStatus = 'active'; // Initialize selected status

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text(
            'Add Junk User Data',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Configure RIoT Card details below:",
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 10,
              ),
              CupertinoPicker(
                diameterRatio: 1.5,
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedCount = index + 1; // Update selected count
                },
                children: List.generate(
                  20,
                  (index) => Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoPicker(
                diameterRatio: 1.5,
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedInOut = index == 0 ? 'in' : 'out';
                  // Update selected "in" or "out"
                },
                children: const <Widget>[
                  Text(
                    'in',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  if (index == 0) {
                    selectedStatus = 'active';
                  } else if (index == 1) {
                    selectedStatus = 'inactive';
                  } else {
                    selectedStatus = 'deleted';
                  }
                },
                children: const <Widget>[
                  Text(
                    'active',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'deleted',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "*Adds selected and configured amount of junk user data to users.",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Use selectedCount, selectedInOut, selectedStatus for your logic
                  _addJunkUserDataToUsers(
                    selectedCount,
                    selectedInOut,
                    selectedStatus,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _removeAllJunkUserData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Remove All Junk Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addJunkUserDataToUsers(
      int count, String inOrOut, String riotCardStatus) async {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      for (int i = 0; i < count; i++) {
        final randomUserID = 'TEST${getRandomString(24)}';
        User newUser = User(
          userName: getRandomString(6).toLowerCase(),
          email: '${getRandomString(8).toLowerCase()}@example.com',
          userType: 'user',
          id: randomUserID,
          dob: "TEST",
          riotCard: {
            'inOrOut': inOrOut,
            'riotCardID': getRandomString(6).toLowerCase(),
            'riotCardStatus': riotCardStatus,
          },
        );

        await usersCollection.doc(randomUserID).set(newUser.toJson());
      }
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        final text = notificationBar(
          text: '$count junk user data added successfully.',
        );
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    } on FirebaseAuthException catch (e) {
      final text = notificationBar(
        text: extractErrorMessage(e.toString()),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    }
  }

  Future<void> _removeAllJunkUserData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('dob', isEqualTo: 'TEST')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          final text = notificationBar(
            text: 'All junk user data is removed.',
          );
          ScaffoldMessenger.of(context).showSnackBar(text);
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          final text = notificationBar(
            text: 'No junk user data to be removed.',
          );
          ScaffoldMessenger.of(context).showSnackBar(text);
        }
      }
    } catch (e) {
      // Handle errors if any
    }
  }

  Future<void> _showRemoveJunkDataDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text(
            'Remove All Junk Data',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              const Text("*Removes all of the junk data from riotCards."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Use selectedCount, selectedInOut, selectedStatus for your logic
                  _removeAllJunkData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddJunkDataDialog(BuildContext context) async {
    int selectedCount = 1; // Initialize selected count
    String selectedInOut = 'in'; // Initialize selected "in" or "out"
    String selectedStatus = 'active'; // Initialize selected status

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text(
            'Add Junk Data',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              CupertinoPicker(
                diameterRatio: 1.5,
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedCount = index + 1; // Update selected count
                },
                children: List.generate(
                    20,
                    (index) => Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
              ),
              const SizedBox(height: 16),
              CupertinoPicker(
                diameterRatio: 1.5,
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedInOut = index == 0
                      ? 'in'
                      : 'out'; // Update selected "in" or "out"
                },
                children: const <Widget>[
                  Text(
                    'in',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'out',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  if (index == 0) {
                    selectedStatus = 'active';
                  } else if (index == 1) {
                    selectedStatus = 'inactive';
                  } else {
                    selectedStatus = 'deleted';
                  }
                },
                children: const <Widget>[
                  Text(
                    'active',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'inactive',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'deleted',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                  "*Adds selected and configured amount of junk data to riotCards."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Use selectedCount, selectedInOut, selectedStatus for your logic
                  _addJunkDataToRiotCards(
                    selectedCount,
                    selectedInOut,
                    selectedStatus,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addJunkDataToRiotCards(
      int count, String inOrOut, String riotCardStatus) async {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    try {
      CollectionReference cardData =
          FirebaseFirestore.instance.collection('riotCards');
      for (int i = 0; i < count; i++) {
        final randomRiotCardID = getRandomString(8).toLowerCase();
        await cardData.doc(randomRiotCardID).set({
          "id": getRandomString(28),
          "inOrOut": inOrOut,
          "riotCardID": randomRiotCardID,
          "riotCardStatus": riotCardStatus,
          "userType": "user",
          "userName": getRandomString(6).toLowerCase(),
          "test": "TEST",
        });
      }
      await FirebaseFirestore.instance
          .collection('labData')
          .doc('lab-metadata')
          .update({'updateStatus': 'outOfDate'});
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        final text = notificationBar(
          text: '$count junk data is/are added successfuly.',
        );
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    } on FirebaseAuthException catch (e) {
      final text = notificationBar(
        text: extractErrorMessage(e.toString()),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(text);
      }
    }
  }

  Future<void> _removeAllJunkData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('riotCards')
          .where('test', isEqualTo: 'TEST')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          await FirebaseFirestore.instance
              .collection('riotCards')
              .doc(doc.id)
              .delete();
        }
        await FirebaseFirestore.instance
            .collection('labData')
            .doc('lab-metadata')
            .update({'updateStatus': 'outOfDate'});
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          final text = notificationBar(
            text: 'All junk is removed from the riotCards.',
          );
          ScaffoldMessenger.of(context).showSnackBar(text);
        }
        //print('Documents deleted successfully.');
      } else {
        //print('No documents found with the given condition.');
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          final text = notificationBar(
            text: 'No junk data to be removed.',
          );
          ScaffoldMessenger.of(context).showSnackBar(text);
        }
      }
    } catch (e) {
      //print(e);
    }
  }

  String extractErrorMessage(String errorMessage) {
    // Find the first occurrence of '[' and ']'
    int startIndex = errorMessage.indexOf('[');
    int endIndex = errorMessage.indexOf(']');

    // Check if both '[' and ']' are present and '[' comes before ']'
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      // Extract the substring excluding the square bracket part
      return errorMessage.substring(endIndex + 1).trim();
    } else {
      // Return the original message if square brackets are not found
      return errorMessage;
    }
  }
}

class AdminLogs extends StatefulWidget {
  final Stream stream;
  final String description;
  final Icon icon;
  const AdminLogs({
    super.key,
    required this.stream,
    required this.description,
    required this.icon,
  });

  @override
  State<AdminLogs> createState() => _AdminLogsState();
}

class _AdminLogsState extends State<AdminLogs> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.02, 0, deviceWidth * 0.02, deviceHeight * 0.02),
        child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              //final labData = snapshot.data!.get(widget.labData);
              return Container(
                  padding: EdgeInsets.fromLTRB(
                      deviceWidth * 0.0,
                      deviceHeight * 0.0,
                      deviceWidth * 0.0,
                      deviceHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                    border: Border.all(
                        width: deviceWidth * 0.01, color: Colors.white),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Text(
                            "Logs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32),
                          ),
                        ),
                        SizedBox(
                          height: deviceHeight * 0.4,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length > 14
                                  ? 14
                                  : snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var doc = snapshot.data!.docs;
                                int reversedIndex =
                                    snapshot.data!.docs.length - 1 - index;

                                Map<String, dynamic> jsonData = {};

                                doc[reversedIndex]
                                    .data()!
                                    .forEach((key, value) {
                                  if (value is! Timestamp) {
                                    jsonData[key] = value;
                                  }
                                });
                                var prettifyJson =
                                    const JsonEncoder.withIndent('  ')
                                        .convert(jsonData);

                                return Container(
                                  padding: EdgeInsets.fromLTRB(
                                      deviceWidth * 0.0,
                                      deviceHeight * 0.0,
                                      deviceWidth * 0.0,
                                      deviceHeight * 0.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(
                                        deviceHeight * 0.01),
                                    border: Border.all(
                                        width: deviceWidth * 0.01,
                                        color: Colors.white),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          widget.icon,
                                          TextButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text(
                                                          "Logs",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "Map of entries: $prettifyJson\n"),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text(
                                                doc[reversedIndex].id,
                                                style: TextStyle(
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize:
                                                        deviceWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        const Text(
                            "*Only shows the last 14 items which are ordered by date."),
                      ],
                    ),
                  ));
            }));
  }
}
