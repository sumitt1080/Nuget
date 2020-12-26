import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String profileType;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.profileType,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

//   factory User.fromDocument(DocumentSnapshot doc) {
//     return User(
//       id: doc['id'],
//       email: doc['email'],
//       profileType: doc['profileType'],
//       username: doc['username'],
//       photoUrl: doc['photoUrl'],
//       displayName: doc['displayName'],
//       bio: doc['bio'],
//     );
//   }
// }
}
