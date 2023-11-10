/// RIoT
/// Custom
/// Classes
/// (rcc)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
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

class User {
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

class LocalException {
  String exception;

  LocalException({required this.exception}) {
    exception = _parseString(exception);
  }

  String _parseString(String exception) {
    return exception.substring(0);
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
                  return const CircularProgressIndicator();
                }

                return Container(
                  padding: EdgeInsets.only(
                      top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              NetworkImage(snapshot.data!.get('pp'))),
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

  Widget buildMenuItems(BuildContext context) {
    return FutureBuilder<Map>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while data is being fetched
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle the error
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                runSpacing: 8,
                children: [
                  userData!["userType"] == "admin"
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
                        FirebaseAuth.instance.signOut().then((value) {
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
        });
  }
}

class ElementPicker extends StatefulWidget {
  final List<String> items;
  final String updateItem;
  const ElementPicker({Key? key, required this.items, required this.updateItem})
      : super(key: key);

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
              Navigator.pop(context);
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
                Navigator.pop(context);
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
      {Key? key, required this.items, required this.onCallback})
      : super(key: key);

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
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
  const ReportMenu({Key? key}) : super(key: key);

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
                    }
                  },
                  child: const Text('Submit'),
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
  final Stream stream;
  final String labData;
  final String description;
  final Icon icon;
  const HomeElement({
    Key? key,
    required this.stream,
    required this.labData,
    required this.description,
    required this.icon,
  }) : super(key: key);

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
      child: StreamBuilder(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final labData = snapshot.data!.get(widget.labData);
            return Container(
              padding: EdgeInsets.fromLTRB(deviceWidth * 0.02,
                  deviceHeight * 0.04, deviceWidth * 0.02, deviceHeight * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                border:
                    Border.all(width: deviceWidth * 0.01, color: Colors.white),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.description,
                    style: TextStyle(
                        fontSize: deviceWidth * 0.035,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      widget.icon,
                      SizedBox(
                        width: deviceWidth * 0.02,
                      ),
                      Text(
                        "$labData",
                        style: TextStyle(
                            fontSize: deviceWidth * 0.08,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
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
  final Map<String, dynamic> updateItem;
  const AdminPanelPicker(
      {Key? key,
      required this.items,
      required this.uID,
      required this.updateItem})
      : super(key: key);

  @override
  State<AdminPanelPicker> createState() => _AdminPanelPickerState();
}

class _AdminPanelPickerState extends State<AdminPanelPicker> {
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
              var updatedCard = widget.updateItem;
              updatedCard['inOrOut'] = widget.items[selectedIndex];
              updateAnotherUser(
                uID: widget.uID,
                riotCard: updatedCard,
              );
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

class AdminUsers extends StatefulWidget {
  final Stream stream;
  //final String labData;
  final String description;
  final Icon icon;
  const AdminUsers({
    Key? key,
    required this.stream,
    //required this.labData,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.05, 0, deviceWidth * 0.05, deviceHeight * 0.04),
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
                      deviceHeight * 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(deviceHeight * 0.01),
                    border: Border.all(
                        width: deviceWidth * 0.01, color: Colors.white),
                  ),
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
                            borderRadius:
                                BorderRadius.circular(deviceHeight * 0.01),
                            border: Border.all(
                                width: deviceWidth * 0.01, color: Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  widget.icon,
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title:
                                                    const Text("User Details"),
                                                content: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                            fontSize: deviceWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )),
                                ],
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.no_accounts)),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title:
                                                const Text("RIoT Card Details"),
                                            content: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      prefixIcon: const Text(
                                                        "inOrOut:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      prefixIconConstraints:
                                                          const BoxConstraints(
                                                              minWidth: 0,
                                                              minHeight: 0),
                                                      hintText:
                                                          "${doc[index]['riotCard']['inOrOut']}\n"),
                                                ),
                                                Text(
                                                    "riotCardID: ${doc[index]['riotCard']['riotCardID']}\n"),
                                                Text(
                                                    "riotCardStatus: ${doc[index]['riotCard']['riotCardStatus']}\n"),
                                                AdminPanelPicker(
                                                    uID: doc[index]['id'],
                                                    items: const ['in', 'out'],
                                                    updateItem: doc[index]
                                                        ['riotCard'])
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.credit_card)),
                            ],
                          ),
                        );
                      }));
            }));
  }
}
