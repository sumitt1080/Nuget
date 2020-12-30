import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart' as head;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final profref = FirebaseFirestore.instance.collection('followers');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: head.header(context, isAppTitle: false, titleText: 'Profile'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FlatButton.icon(
          onPressed: () {
            return showDialog(
                context: context,
                builder: (context) {
                  return Container(
                    height: 100.0,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: SimpleDialog(
                        title: Text(
                          "Logout",
                          style: TextStyle(fontFamily: "Sailing_Heart"),
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
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              RaisedButton(
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
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
                });
          },
          icon: Icon(Icons.cancel, color: Colors.red),
          label: Text(
            "Logout",
            style: TextStyle(color: Color(0xFFFE1A1A), fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
