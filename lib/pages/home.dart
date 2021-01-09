import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuget/pages/activity_feed.dart';
import 'package:nuget/pages/profile.dart';
import 'package:nuget/pages/ClubList.dart';
import 'package:nuget/pages/timeline.dart';
import 'package:nuget/pages/upload.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';
import '../widgets/header.dart' as head;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<String> _stream;
  PageController pageController;
  int pageIndex = 0;
  String uniProfileType;
  Map<String, dynamic> map;

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

  Widget buildNavBar(String type) {
    print('----buildNavBar------');
    print(type);
    if (uniProfileType == 'Club') {
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

  List<Widget> navFunctions(String type) {
    print('-=-=-navFunction-=-==-');
    print(type);
    List<Widget> l1 = [
      Timeline(
        map: map,
        type: uniProfileType,
      ),
      ActivityFeed(
        profType: uniProfileType,
        map: map,
      ),
      Upload(),
      ClubList(
        map: map,
      ),
      Profile(),
    ];
    List<Widget> l2 = [
      Timeline(
        map: map,
        type: uniProfileType,
      ),
      ActivityFeed(
        profType: uniProfileType,
        map: map,
      ),
      ClubList(
        map: map,
      ),
      Profile(),
    ];
    if (uniProfileType == 'Club') {
      return l1;
    } else {
      return l2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar =
        head.header(context, isAppTitle: false, titleText: 'Timeline');

    return StreamBuilder<String>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FloatingActionButton floatingActionButton;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: slider,
            );
          }

          print('Here baby: ${uniProfileType}');

          if (uniProfileType == 'Club') {
            uniProfileType = 'Club';
          } else {
            uniProfileType = 'Student';
          }
          print(map);

          return Scaffold(
            //appBar: head.header(context, isAppTitle: false, titleText: 'Timeline'),
            body: PageView(
              children: navFunctions(snapshot.data),
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
            //floatingActionButton: floatingActionButton,
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
        .asyncMap(
          (user) => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
        )
        .map((doc) {
      uniProfileType = doc.data()['profileType'];
      map = doc.data()['subscribedTo'];
    });
  }
}
