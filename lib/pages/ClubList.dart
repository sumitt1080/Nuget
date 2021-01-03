import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'home.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart' as head;

class ClubList extends StatefulWidget {
  @override
  _ClubListState createState() => _ClubListState();
}

class _ClubListState extends State<ClubList> {
  String pid;

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      pid = uid;
    });
  }

  bool isFollowing = false;

  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  CollectionReference subscribersRef =
      FirebaseFirestore.instance.collection('subscribers');

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  checkIfFollowing(String cardID) async {
    print(cardID);
    print(pid);
    bool check = false;
    DocumentSnapshot doc = await subscribersRef
        .doc(cardID)
        .collection('userSubscribers')
        .doc(pid)
        .get();
    check = doc.exists;
    print('Exists? : ${doc.exists}');
    // print('Check?: $check');
    //return check;
    //Future.delayed(Duration(milliseconds: 20));

    if (doc.exists) {
      return true;
    } else {
      return false;
    }
    // setState(() {
    //   isFollowing = doc.exists;
    // });
  }

  handleUnfollowUser(String cardID) {
    setState(() {
      isFollowing = false;
    });
    subscribersRef
        .doc(cardID)
        .collection('userFollowers')
        .doc(pid)
        .get()
        .then((doc) {
      doc.reference.delete();
    });
  }

  handleFollowUser(String cardID) {
    // setState(() {
    //   isFollowing = true;
    // });
    subscribersRef.doc(cardID).collection('userSubscribers').doc(pid).set({});
    //subscribeButton();
  }

  Container buildButton({String text, Function function, Color color}) {
    print('You are in buildButton Function:');
    print(text);
    print(function);
    print(color);
    return Container(
      child: FlatButton(
        onPressed: function,
        child: Text(
          text,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  Widget subscribeButton(String cardID) {
    print('Here: $cardID');
    print(cardID);
    var check = checkIfFollowing(cardID);
    print('SubscribeButtonCheck: ${check}');
    if (checkIfFollowing(cardID) == true) {
      print('Entered in true');
      return buildButton(
          text: 'Subscribed',
          function: handleUnfollowUser(cardID),
          color: Colors.grey);
    } else if (checkIfFollowing(cardID) == false) {
      print('Entered in false');
      return buildButton(
        text: 'Subscribe',
        function: handleFollowUser(cardID),
        color: Colors.red,
      );
    } else {
      return slider;
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: head.header(context, isAppTitle: false, titleText: 'Clubs'),
      backgroundColor: Color(0xFFfaf0e6),
      body: StreamBuilder(
        stream: usersRef.where('profileType', isEqualTo: 'Club').snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    shadowColor: Color(0xFF848482),
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                documents[index]['club'],
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                documents[index]['email'],
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                child: subscribeButton(
                                    documents[index].documentID),
                                // FlatButton(
                                //   child: Text(
                                //     'Subscribe',
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                //   onPressed: () {
                                //     print(documents[index].documentID);
                                //     print('Subscribe Button pressed');
                                //     handleFollowUser(
                                //         documents[index].documentID);
                                //     checkIfFollowing(
                                //         documents[index].documentID);
                                //   },
                                // ),
                              ),
                            ],
                          ),
                          // // checkIfFollowing(documents[index].documentID)
                          // //     ? Column(
                          // //         children: [
                          // //           GestureDetector(
                          // //             child: FlatButton(
                          // //               child: Text(
                          // //                 'Subscribe',
                          // //                 style: TextStyle(color: Colors.red),
                          // //               ),
                          // //               onPressed: () {
                          // //                 print(documents[index].documentID);
                          // //                 print('Subscribe Button pressed');
                          // //                 handleFollowUser(
                          // //                     documents[index].documentID);
                          // //               },
                          // //             ),
                          // //           ),
                          // //         ],
                          // //       )
                          // //     : Column(
                          // //         children: [
                          // //           GestureDetector(
                          // //             child: FlatButton(
                          // //               child: Text(
                          // //                 '✔️Subscribed',
                          // //                 style: TextStyle(color: Colors.grey),
                          // //               ),
                          // //               onPressed: () {
                          // //                 print(documents[index].documentID);
                          // //                 print('Subscribe Button pressed');
                          // //                 handleFollowUser(
                          // //                     documents[index].documentID);
                          // //               },
                          // //             ),
                          // //           ),
                          // //         ],
                          // //       ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
