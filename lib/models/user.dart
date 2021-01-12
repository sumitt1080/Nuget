class User {
  String profileType;
  Map<String, dynamic> subscribedTo;

  User({
    this.profileType,
    this.subscribedTo,
  });

  User.fromMap(Map<String, dynamic> map) {
    profileType = map['profileType'];
    subscribedTo = map['subscribedTo'];
  }
}
