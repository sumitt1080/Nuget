import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Align(
      alignment: Alignment.topCenter,
      child: ConnectionStatusBar(
        title: Text('No Network Connectivity'),
      ),
    );
    return MaterialApp(
      title: 'Nuget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.teal,
      ),
      home: Home(),
    );
  }
}
