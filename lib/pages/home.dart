import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool isAuth = false;
  TabController _tabController;

  TextEditingController _controller2;
  TextEditingController _controller3;
  TextEditingController _controller4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);

    _controller2 = TextEditingController(text: DateTime.now().toString());
    _controller3 = TextEditingController(text: DateTime.now().toString());

    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    _controller4 = TextEditingController(text: '$lsHour:$lsMinute');
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print('User signed in!: $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  Widget buildAuthScreen() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.purple,
            hoverColor: Colors.green,
            hoverElevation: 50.0,
            child: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet<void>(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                         // Padding(
                            //padding: EdgeInsets.all(8.0),
                             TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Event Name',
                                labelText: 'Event',
                                icon: Icon(Icons.details)
                              ),
                              
                            ),
                         // ),
                          DateTimePicker(
                            type: DateTimePickerType.dateTime,
                            dateMask: 'yyyy/MM/dd',
                            controller: _controller3,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            icon: Icon(Icons.event),
                            dateLabelText: 'Date',
                          ),
                          DateTimePicker(
                            type: DateTimePickerType.time,
                            controller: _controller4,
                            //initialValue: _initialValue,
                            icon: Icon(Icons.access_time),
                            timeLabelText: "Time",
                            //use24HourFormat: false,
                            //locale: Locale('en', 'US'),
                          ),
                        ],
                      ),
                    );
                  });
            }),
        appBar: ShiftingTabBar(
          controller: _tabController,
          color: Color(0xFF0198E1),
          tabs: [
            ShiftingTab(icon: Icon(LineAwesomeIcons.list_ul), text: 'Task'),
            ShiftingTab(icon: Icon(LineAwesomeIcons.fire), text: 'Feed'),
            ShiftingTab(icon: Icon(LineAwesomeIcons.user_1), text: 'Clubs'),
          ],
        ),
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nuget',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
