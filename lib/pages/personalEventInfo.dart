import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:intl/intl.dart';

class PersonalEventInfo extends StatelessWidget {
  String eveId;
  String title;
  PersonalEventInfo({this.eveId, this.title});

  CollectionReference perevent =
      FirebaseFirestore.instance.collection('privateEvent');
  DateFormat format = new DateFormat("h:mm a");

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: perevent.doc(eveId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            //return Text("Event: ${data['Event']} ${data['Organiser']}");
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                shadowColor: Color(0xFF848482),
                elevation: 5.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event: ${data['Event']}',
                      style: TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                   
                     Text(
                      'Description: ${data['Description']}',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w400),
                    ),
                     Text(
                      'Date: ${data['Date']}',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Starting from: ${data['Start Time']}',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w400),
                    ),
                     Text(
                      'At: ${data['Venue']}',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w400),
                    ),
                    
                  ],
                ),
              ),
            );
          }

          return Center(
            child: slider,
          );
        },
      ),
    );
  }
}
