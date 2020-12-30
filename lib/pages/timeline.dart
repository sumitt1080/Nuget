import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nuget/widgets/post.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../widgets/header.dart' as header;
import '../widgets/header.dart';
import 'dart:convert';
import 'EventDetail.dart';
import '../widgets/post.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  CollectionReference eventref = FirebaseFirestore.instance.collection('event');

  final GlobalKey _refreshIndicatorKey = GlobalKey();
  String profileId;
  String eveID;
  String title;
  String date;

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final pid = user.uid;
    setState(() {
      profileId = pid;
    });
  }

  //int length;
  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  bool isOwner(String id) {
    print('ID-------');
    print('Current id: $profileId');
    print(id);
    if (profileId == id) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteUser(String id) {
    return eventref
        .doc(id)
        .delete()
        .then((value) => print("User Deleted:"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  @override
  Widget build(context) {
    //getEvents();
    return Scaffold(
      body: StreamBuilder(
        stream: eventref.orderBy('Date', descending: true).snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            print('You are here');
            return Center(
              child: slider,
            );
          }

          final documents = streamSnapshot.data.documents;
          print(streamSnapshot.data.documents.length);

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) => Container(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                child: InkWell(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    shadowColor: Color(0xFF848482),
                    elevation: 5.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documents[index]['Event'],
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              documents[index]['Organiser'],
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'On ${documents[index]['Date']} At ${documents[index]['Start Time']}',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        isOwner(documents[index]['Owner'])
                            ? Column(
                                children: [
                                  FlatButton(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      String docId =
                                          documents[index].documentID;

                                      print(documents[index].documentID);

                                      // DocumentReference ref = FirebaseFirestore.instance.doc(documents[index].documentID);
                                      //print(ref.path);
                                      deleteUser(docId);
                                    },
                                  ),
                                ],
                              )
                            : Column(),
                        Column(
                          children: [Icon(Icons.notifications_active)],
                        )
                      ],
                    ),
                  ),
                  // onLongPress: () {
                  //   return showDialog(
                  //     builder: (BuildContext context) {
                  //       return AlertDialog(
                  //         content: Column(
                  //           children: [
                  //             Text(
                  //               'Starting From:${documents[index]['Start Time']}',
                  //               style: TextStyle(
                  //                   fontSize: 20.0,
                  //                   fontWeight: FontWeight.w400),
                  //             ),
                  //             Text(
                  //               'At:${documents[index]['Venue']}',
                  //               style: TextStyle(
                  //                   fontSize: 20.0,
                  //                   fontWeight: FontWeight.w400),
                  //             ),
                  //             Text(
                  //               'You should Come',
                  //               style: TextStyle(
                  //                   fontSize: 20.0,
                  //                   fontWeight: FontWeight.w400),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   );
                  // },
                ),
                onTap: () {
                  eveID = documents[index].documentID;
                  title = documents[index]['Event'];
                  print(eveID);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetail(
                            eveId: eveID,
                            title: title,
                          )));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
