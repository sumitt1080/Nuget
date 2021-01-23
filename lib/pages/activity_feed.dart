import 'dart:developer';
import 'package:nuget/pages/infoPostDetail.dart';

import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuget/pages/EventDetail.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class ActivityFeed extends StatefulWidget {
  ActivityFeed({this.profType, this.map});
  String profType;
  Map<String, dynamic> map;
  @override
  _ActivityFeedState createState() => _ActivityFeedState(profType, map);
}

class _ActivityFeedState extends State<ActivityFeed>
    with TickerProviderStateMixin {
  String proftype;
  Map<String, dynamic> map;
  _ActivityFeedState(this.proftype, this.map);
  CollectionReference infoEvent =
      FirebaseFirestore.instance.collection('infoPost');

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  final detailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> list = new List();
  String profileId;

  String eveID;
  String title;

  bool isaClub = true;
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  TextEditingController _controller5;
  TextEditingController _controller1;

  Animation<double> _animation;
  AnimationController _animationController;

  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final pid = user.uid;
    isClub();

    setState(() {
      profileId = pid;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  String eventName;
  String organiser;
  String detail;
  String url;
  bool _isLoading = false;

  void mapToList() {
    print(map);
    map.forEach((key, value) {
      if (value.toString() == 'true') {
        list.add(key);
      }
    });
  }

  _fetchClub() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(profileId)
        .get();
    organiser = result.data()['club'];
  }

  Future<void> submit() async {
    _formKey.currentState.save();
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('infoPost').doc().set({
        'TimeStamp': Timestamp.now(),
        'Organiser': organiser,
        'Event': eventName,
        'URL': url,
        'Description': detail,
        'Owner': profileId,
      });
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print(err);
    }
  }

  _showForm() {
    return showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(25.0),
            topRight: const Radius.circular(25.0),
          ),
        ),
        isScrollControlled: false,
        enableDrag: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Event Name',
                          labelText: 'Event',
                          icon: Icon(Icons.event_note)),
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      onSaved: (value) {
                        eventName = value;
                      }),
                  TextFormField(
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                          hintText: 'Info URL',
                          labelText: 'URL',
                          icon: Icon(Icons.event_note)),
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      onSaved: (value) {
                        url = value;
                      }),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter Description',
                      icon: Icon(Icons.description),
                    ),
                    controller: detailController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (value) {
                      detail = value;
                    },
                    onChanged: (value) {
                      detail = value;
                    },
                  ),
                  RaisedButton(
                    child: _isLoading ? slider : Text('Submit'),
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    onPressed: () {
                      Navigator.pop(context);
                      _animationController.reverse();
                      submit();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool isOwner(String id) {
    if (profileId == id) {
      return true;
    } else {
      return false;
    }
  }

  isClub() {
    if (proftype == 'Club') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteUser(String id) {
    return infoEvent
        .doc(id)
        .delete()
        .then((value) => print("User Deleted:"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  containID(String cardID) {
    if (list.contains(cardID)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _fetchClub();
    mapToList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      backgroundColor: Color(0xFFfaf0e6),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isClub()
          ? FloatingActionBubble(
              animation: _animation,
              items: [
                Bubble(
                  title: "Pin Information",
                  bubbleColor: Colors.blue,
                  iconColor: Colors.white,
                  icon: Icons.add,
                  titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                  onPress: () {
                    return _showForm();
                  },
                ),
              ],
              onPress: () => _animationController.isCompleted
                  ? _animationController.reverse()
                  : _animationController.forward(),
              iconColor: Colors.white,
              iconData: Icons.expand,
              backGroundColor: Colors.green,
            )
          : Column(),
      body: StreamBuilder(
        stream: infoEvent.snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: slider,
            );
          }
          if (!streamSnapshot.hasData) {
            return Center(
              child: Text('Nothing here'),
            );
          }

          final documents = streamSnapshot.data.documents;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) => Container(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                child: InkWell(
                  child: containID(documents[index]['Owner'])
                      ? Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          shadowColor: Color(0xFF848482),
                          elevation: 10.0,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      documents[index]['Event'],
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      documents[index]['Organiser'],
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                  ],
                                ),
                                isOwner(documents[index]['Owner'])
                                    ? Column(
                                        children: [
                                          FlatButton(
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              String docId =
                                                  documents[index].documentID;

                                              deleteUser(docId);
                                            },
                                          ),
                                        ],
                                      )
                                    : Column(),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
                onTap: () {
                  eveID = documents[index].documentID;
                  title = documents[index]['Event'];
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InfoPostDetail(
                            eveId: documents[index].documentID,
                            title: documents[index]['Event'],
                          )));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
