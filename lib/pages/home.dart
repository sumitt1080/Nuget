import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuget/models/profilemodal.dart';
import 'package:nuget/models/user.dart';
import 'package:nuget/pages/activity_feed.dart';
import 'package:nuget/pages/create_account.dart';
import 'package:nuget/pages/profile.dart';
import 'package:nuget/pages/search.dart';
import 'package:nuget/pages/timeline.dart';
import 'package:nuget/pages/upload.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    buildNavBar(currentUser.profileType);
    pageController = PageController();
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
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    //ProfileModal profile;
    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      ProfileModal profile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      print('--@--@--@');
      print(profile.profiletype);
      print('########');
      print(profile.username);

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": profile.username,
        "profileType": profile.profiletype,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      doc = await usersRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.profileType);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildNavBar(String type) {
    print('----nav------');
    print(type);
    if (type == 'Club') {
      return CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_sharp),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
            ),
          ]);
    } else {
      return CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_sharp),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
            ),
          ]);
    }
  }

  List<Widget> navFunctions(String type) {
    print('-=-=-navFunction-=-==-');
    print(type);
    List<Widget> l1 = [
      //Timeline(),
      RaisedButton(
        child: Text('Logout'),
        onPressed: logout,
      ),
      ActivityFeed(),
      Upload(),
      Search(),
      Profile(),
    ];
    List<Widget> l2 = [
      //Timeline(),
      RaisedButton(
        child: Text('Logout'),
        onPressed: logout,
      ),
      ActivityFeed(),
      Search(),
      Profile(),
    ];
    if (type == 'Club') {
      return l1;
    } else {
      return l2;
    }
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
        body: PageView(
          children: navFunctions(currentUser.profileType),
          // <Widget>[
          //   //Timeline(),
          //   RaisedButton(
          //     child: Text('Logout'),
          //     onPressed: logout,
          //   ),
          //   ActivityFeed(),
          //   Search(),
          //   Profile(),
          // ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: buildNavBar(currentUser.profileType)
        // CupertinoTabBar(
        //     currentIndex: pageIndex,
        //     onTap: onTap,
        //     activeColor: Theme.of(context).primaryColor,
        //     items: [
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.whatshot),
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.event_available_sharp),
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.search),
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.group_rounded),
        //       ),
        //     ]),
        );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
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
              'FlutterShare',
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
