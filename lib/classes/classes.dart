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

class RiotCard {
  String id;
  final String inOrOut;
  final String riotCardID;
  final String riotCardStatus;
  final String userName;

  RiotCard({
    this.id = '',
    this.inOrOut = '',
    this.riotCardID = '',
    this.riotCardStatus = '',
    this.userName = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'inOrOut': inOrOut,
        'riotCardID': riotCardID,
        'riotCardStatus': riotCardStatus,
        'userName': userName,
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
                  //NetworkImage(snapshot.data!.get('pp'))
                  return const Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("NO CONNECTION")
                    ],
                  );
                }

                return Container(
                  padding: EdgeInsets.only(
                      top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        child: Image.network(
                          snapshot.data!.get('pp'),
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  AssetImage('assets/images/default-pp.jpg'),
                            );
                          },
                        ),
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
                  const Text("v1.0.0"),
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
  final String updateElement;
  final String initialItem;
  final Function(String data, String dataType) updateParent;
  final Map<String, dynamic> updateItem;
  const AdminPanelPicker(
      {Key? key,
      required this.items,
      required this.uID,
      required this.updateElement,
      required this.initialItem,
      required this.updateParent,
      required this.updateItem})
      : super(key: key);

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
    Key? key,
    required this.stream,
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
            deviceWidth * 0.02, 0, deviceWidth * 0.02, deviceHeight * 0.00),
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
                        ListView.builder(
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
                                                  fontSize: deviceWidth * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
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
                                                                    .docs[index]
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
                                            icon:
                                                const Icon(Icons.credit_card)),
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text(
                                                        "Change User Status",
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
                                                                    .docs[index]
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
                                                          AdminUpdateUserType(
                                                            uID: doc[index]
                                                                ['id'],
                                                            items: const [
                                                              'user',
                                                              'banned',
                                                              'admin'
                                                            ],
                                                            initialItem: doc[
                                                                    index]
                                                                ['userType'],
                                                          ),
                                                        ],
                                                      ),
                                                    );
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
    Key? key,
    required this.document,
    required this.index,
  }) : super(key: key);

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
          onTap: () {
            var updatedCard = widget.document[widget.index]['riotCard'];
            updatedCard['riotCardID'] = riotCardIDState;
            updatedCard['riotCardStatus'] = riotCardStatusState;
            updatedCard['inOrOut'] = inOrOutState;
            synchronizeRiotCards(widget.document[widget.index]['id'],
                widget.document[widget.index]['userName'], updatedCard);
            updateAnotherUser(
                    uID: widget.document[widget.index]['id'],
                    riotCard: updatedCard)
                .then((value) => Navigator.pop(context));
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
  const AdminUpdateUserType({
    Key? key,
    required this.items,
    required this.uID,
    required this.initialItem,
  }) : super(key: key);

  @override
  State<AdminUpdateUserType> createState() => _AdminUpdateUserTypeState();
}

class _AdminUpdateUserTypeState extends State<AdminUpdateUserType> {
  int initialItemIndex = 0;
  late FixedExtentScrollController _scrollController;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    initialItemIndex = widget.items.indexOf(widget.initialItem);
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
              updateAnotherUser(
                      uID: widget.uID, userType: widget.items[selectedIndex])
                  .then((value) => Navigator.pop(context));
            },
          ),
        ],
      ),
    );
  }
}
