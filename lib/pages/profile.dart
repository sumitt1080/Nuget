import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final profref = FirebaseFirestore.instance.collection('followers');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Profile"),
    );
  }
}
