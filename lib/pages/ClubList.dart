import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../models/user.dart';
import 'home.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart' as head;

class ClubList extends StatefulWidget {
  @override
  _ClubListState createState() => _ClubListState();
}

class _ClubListState extends State<ClubList> {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

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
                    padding:  EdgeInsets.all(12.0),
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
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              documents[index]['email'],
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.0,),
                        Column(
                          children: [
                            GestureDetector(
                              child: FlatButton(
                                child: Text(
                                  'Subscribe',
                                  style: TextStyle(color: Colors.red, fontSize: 15.0),
                                ),
                                onPressed: () {
                                  print(documents[index].documentID);
                                  print('Subscribe Button pressed');
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
    ),);
  }
}
