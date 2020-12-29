import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String id;
  final String event;
  final String organiser;
  final String description;
  final String date;
  final String startTime;

  EventCard({
    this.id,
    this.event,
    this.organiser,
    this.description,
    this.date,
    this.startTime,
  });
  int count = 0;

  factory EventCard.fromMap(Map<String, dynamic> doc) {
    return EventCard(
      id: doc['id'],
      event: doc['Event'],
      organiser: doc['Organiser'],
      description: doc['Description'],
      date: doc['Date'],
      startTime: doc['Start Time'],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(child: Text((++count).toString()));
  }
}
