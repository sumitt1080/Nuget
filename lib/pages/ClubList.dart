import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'home.dart';

import '../widgets/header.dart' as head;

class ClubList extends StatefulWidget {
  ClubList({this.map, this.ptype});
  Map<String, dynamic> map;
  String ptype;
  @override
  _ClubListState createState() => _ClubListState(list: map, ptype: ptype);
}

class _ClubListState extends State<ClubList> {
  _ClubListState({this.list, this.ptype});
  String pid;
  Map<String, dynamic> list;
  String ptype;

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

  checkSubscribe(String cardID) {
    if (list[cardID].toString() == 'true') {
      return true;
    } else {
      return false;
    }
  }

  isListNull() {
    if (list == null) {
      return true;
    } else {
      return false;
    }
  }

  isClub() {
    if (ptype == 'Club') {
      return true;
    } else {
      return false;
    }
  }

  removeSubscribe(String cardID) async {
    await usersRef.doc(pid).update({'subscribedTo.$cardID': false});
    print('done done');
  }

  addSubscribe(String cardID) async {
    await usersRef.doc(pid).update({'subscribedTo.$cardID': true});
    print('Done');
  }

  @override
  Widget build(BuildContext context) {
    //fetchSubscribeList();

    //checkIfFollowing('fRKKGKIf8yfuZLInhqZRk8C7UyZ2');
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
                         
                              list.isEmpty
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          child: FlatButton(
                                            child: Text(
                                              'Subscribe',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15.0),
                                            ),
                                            onPressed: () {
                                              addSubscribe(
                                                  documents[index].documentID);
                                              setState(() {
                                                list[documents[index]
                                                        .documentID] =
                                                    'true' as dynamic;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          child: checkSubscribe(
                                                  documents[index].documentID)
                                              ? FlatButton(
                                                  child: Text('✔️Subscribed'),
                                                  onPressed: () {
                                                    removeSubscribe(
                                                        documents[index]
                                                            .documentID);
                                                    setState(() {
                                                      //fetchSubscribeList();
                                                      list[documents[index]
                                                              .documentID] =
                                                          'false' as dynamic;
                                                      print(list[
                                                          documents[index]
                                                              .documentID]);
                                                    });
                                                  },
                                                )
                                              : FlatButton(
                                                  child: Text(
                                                    'Subscribe',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15.0),
                                                  ),
                                                  onPressed: () {
                                                    addSubscribe(
                                                        documents[index]
                                                            .documentID);
                                                    setState(() {
                                                      list[documents[index]
                                                              .documentID] =
                                                          'true' as dynamic;
                                                      print(list[
                                                          documents[index]
                                                              .documentID]);
                                                    });
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
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
