import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuget/pages/activity_feed.dart';
import 'package:nuget/pages/profile.dart';
import 'package:nuget/pages/search.dart';
import 'package:nuget/pages/timeline.dart';
import 'package:nuget/pages/upload.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';

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
    if (type == 'Club') {
      return CupertinoTabBar(
          // currentIndex: pageIndex,
          // onTap: onTap,
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
          // currentIndex: pageIndex,
          // onTap: onTap,
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
      Timeline(),
      ActivityFeed(),
      Upload(),
      Search(),
      Profile(),
    ];
    List<Widget> l2 = [
      Timeline(),
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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Nuget'),
      actions: [
        DropdownButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          items: [
            DropdownMenuItem(
              child: Container(
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text('Logout,')
                  ],
                ),
              ),
              value: 'logout',
            ),
          ],
          onChanged: (itemIdentifier) {
            if (itemIdentifier == 'logout') {
              FirebaseAuth.instance.signOut();
            }
          },
        ),
      ],
    );

    return StreamBuilder<String>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FloatingActionButton floatingActionButton;

          if (snapshot.data == 'Club') {
            // floatingActionButton = FloatingActionButton(
            //   onPressed: () {},
            //   child: Icon(Icons.add),
            // );
          }

          return Scaffold(
            appBar: appBar,
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
        .map(
          (doc) => doc.data()['profileType'],
        );
  }
}
