import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:nuget/models/user.dart';
import 'package:nuget/pages/activity_feed.dart';
import 'package:nuget/pages/profile.dart';
import 'package:nuget/pages/ClubList.dart';
import 'package:nuget/pages/timeline.dart';
import 'package:nuget/pages/upload.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';
import '../widgets/header.dart' as head;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<User> _stream;
  PageController pageController;
  int pageIndex = 0;

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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

  Widget buildNavBar(User user) {
    if (user.profileType == 'Club') {
      return CurvedNavigationBar(
          index: pageIndex,
          onTap: onTap,
          backgroundColor: Colors.blueAccent,
          height: 50.0,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 200),
          buttonBackgroundColor: Colors.white,
          items: [
            Icon(Icons.whatshot),
            Icon(Icons.event_available_sharp),
            Icon(
              Icons.add,
              size: 40,
            ),
            Icon(Icons.list),
            Icon(Icons.group_rounded),
          ]);
    } else {
      return CurvedNavigationBar(
          index: pageIndex,
          onTap: onTap,
          backgroundColor: Colors.blueAccent,
          height: 50.0,
          animationCurve: Curves.easeIn,
          animationDuration: Duration(milliseconds: 200),
          buttonBackgroundColor: Colors.white,
          items: [
            Icon(Icons.whatshot),
            Icon(Icons.event_available_sharp),
            Icon(Icons.list),
            Icon(Icons.group_rounded),
          ]);
    }
  }

  List<Widget> navFunctions(User user) {
    List<Widget> l1 = [
      Timeline(
        map: user.subscribedTo,
        type: user.profileType,
      ),
      ActivityFeed(
        profType: user.profileType,
        map: user.subscribedTo,
      ),
      Upload(),
      ClubList(
        map: user.subscribedTo,
      ),
      Profile(),
    ];
    List<Widget> l2 = [
      Timeline(
        map: user.subscribedTo,
        type: user.profileType,
      ),
      ActivityFeed(
        profType: user.profileType,
        map: user.subscribedTo,
      ),
      ClubList(
        map: user.subscribedTo,
      ),
      Profile(),
    ];
    if (user.profileType == 'Club') {
      return l1;
    } else {
      return l2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar =
        head.header(context, isAppTitle: false, titleText: 'Timeline');

    return StreamBuilder<User>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FloatingActionButton floatingActionButton;

          if (!snapshot.hasData) {
            return Center(
              child: slider,
            );
          }


          if (snapshot.data.profileType == 'Club') {
            floatingActionButton = FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            );
          }


          return Scaffold(
            //appBar: head.header(context, isAppTitle: false, titleText: 'Timeline'),
            body: PageView(
              children: navFunctions(snapshot.data),
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: buildNavBar(snapshot.data),
          );
        } else {
          return Scaffold(
            appBar: appBar,
            body: Center(
              child: slider,
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _stream = FirebaseAuth.instance
        .authStateChanges()
        .switchMap(
          (user) => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
        )
        .map(
          (doc) => User.fromMap(doc.data()),
        );
  }
}
