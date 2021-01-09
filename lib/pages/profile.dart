import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuget/pages/activity_feed.dart';
import '../widgets/header.dart' as head;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final profref = FirebaseFirestore.instance.collection('followers');
  CollectionReference currentref =
      FirebaseFirestore.instance.collection('users');

  String profileid, username, email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    profileid = uid;
  }

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: head.header(context, isAppTitle: false, titleText: 'Profile'),
     
      body: FutureBuilder<DocumentSnapshot>(
        future: currentref.doc(profileid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: slider);

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                shadowColor: Color(0xFF848482),
                elevation: 5.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(data['image_url']),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.all(5),
                        child: Text(
                          'Username: ${data['username']}',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.all(5),
                        child: Text(
                          'E-mail: ${data['email']}',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 8,
                          margin: EdgeInsets.all(5),
                          child: Text(
                            'SignedIn as: ${data['profileType']}',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    SizedBox(height: 40),
                    Center(
                      child: FlatButton.icon(
                        onPressed: () {
                          return showDialog(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 100.0,
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: SimpleDialog(
                                    title: Text(
                                      "Logout",
                                      style: TextStyle(
                                          fontFamily: "Sailing_Heart"),
                                      textAlign: TextAlign.center,
                                    ),
                                    children: <Widget>[
                                      SizedBox(
                                        height: 7.0,
                                      ),
                                      Column(
                                        children: [
                                          Text("Are you sure to Logout ? "),
                                          SizedBox(
                                            height: 7.0,
                                          ),
                                          RaisedButton(
                                            color: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                            ),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            onPressed: () {
                                              
                                              Navigator.pop(context);
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                            ),
                                            child: Text(
                                              "Logout",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);

                                              FirebaseAuth.instance.signOut();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text(
                          "Logout",
                          style: TextStyle(
                              color: Color(0xFFFE1A1A), fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
