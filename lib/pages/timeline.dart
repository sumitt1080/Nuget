import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuget/widgets/post.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../widgets/header.dart';
import 'dart:convert';
//import '../models/Event_card_modal.dart';
import '../widgets/post.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  CollectionReference eventref = FirebaseFirestore.instance
      .collection('event')
      .doc(uid)
      .collection('post');

  int length;
  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  //bool _isLoading = false;
  String event;
  getEvents() async {
    List<Widget> list = [];

    QuerySnapshot result = await eventref.get();
    length = result.docs.length;
    print(length);
    for (var res in result.docs) {
      // Stream<DocumentSnapshot> post =
      // print(post.length);

      print(res.get(
        'Event',
      ));
      print(res.get('Organiser'));
      print('-------------');
      Card card = new Card(
        child: Row(
          children: [
            Column(
              children: [Text(res.get('Event')), Text(res.get('Date'))],
            ),
            Column(
              children: [
                Text(res.get('Organiser')),
                Text(res.get('Start Time'))
              ],
            ),
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ],
        ),
      );
      list.add(card);
      print(list);
    }
    return list;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(context) {
    //getEvents();
    return Scaffold(
      body: StreamBuilder(
        stream: eventref.snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            print('Yaha hai bsdk');
            return Center(
              child: slider,
            );
          }
          final documents = streamSnapshot.data.documents;
          print(streamSnapshot.data.documents.length);
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) => Container(
              padding: EdgeInsets.all(8),
              child: Text(documents[index]['Organiser']),
            ),
          );
        },
      ),
    );
  }
}
