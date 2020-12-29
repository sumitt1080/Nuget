import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Post extends StatefulWidget {
  final String id;
  final String event;
  final String organiser;
  final String description;
  final String date;
  final String startTime;

  Post({
    this.id,
    this.event,
    this.organiser,
    this.description,
    this.date,
    this.startTime,
  });

  factory Post.fromMap(Map<String, dynamic> doc) {
    return Post(
      id: doc['id'],
      event: doc['Event'],
      organiser: doc['Organiser'],
      description: doc['Description'],
      date: doc['Date'],
      startTime: doc['Start Time'],
    );
  }

  @override
  _PostState createState() => _PostState(
        id: this.id,
        event: this.event,
        organiser: this.organiser,
        description: this.description,
        date: this.date,
        startTime: this.startTime,
      );
}

class _PostState extends State<Post> {
  final String id;
  final String event;
  final String organiser;
  final String description;
  final String date;
  final String startTime;

  _PostState({
    this.id,
    this.event,
    this.organiser,
    this.description,
    this.date,
    this.startTime,
  });

  CollectionReference eventref = FirebaseFirestore.instance
      .collection('event')
      .doc(uid)
      .collection('post');

  final slider = SleekCircularSlider(
    appearance: CircularSliderAppearance(
      spinnerMode: true,
      size: 50.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: eventref.doc().get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Gand Marao'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print('Kuch Hai');
          Map<String, dynamic> data = snapshot.data.data();
          print(data);

          return Text("Event: ${data}");
        }
        return Center(
          child: slider,
        );
      },
    );
  }
}
