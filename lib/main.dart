import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import './pages/home.dart';
import './pages/auth_screen.dart';



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
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            var arr = userSnapshot.data.toString().split(',');
            print('--before uid----');
            String arr1 = arr[17].split(',').toString();
            String uid = arr1.split(':')[1].split(')')[0];
            print(uid);

            // FirebaseFirestore.instance
            //     .collection('users')
            //     .doc(uid)
            //     .get()
            //     .then((DocumentSnapshot doc) {
            //   print('---Data-----');
            //   print(doc.data());
            // });
            return MyHomePage();
          }
          return AuthScreen();
        },
      ),
    );
  }
}
