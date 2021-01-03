import 'dart:developer';

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
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed>
    with TickerProviderStateMixin {
  CollectionReference infoEvent =
      FirebaseFirestore.instance.collection('infoPost');

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  final detailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String profileId;

  String eveID;
  String title;

  String _valueChanged1 = '';
  String _valueToValidate1 = '';
  bool isaClub = false;
//  DateTime _valueSaved1 = null;
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
  bool _isLoading;

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
      await FirebaseFirestore.instance.collection('infoPost').doc()
          // .collection('post')
          // .doc()
          .set({
        'TimeStamp': Timestamp.now(),
        'Organiser': organiser,
        'Event': eventName,
        'URL': url,
        'Description': detail,
        'Owner': profileId,
        // 'Duration': dur,
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
                        print('Event: $eventName');
                      }),
                  TextFormField(
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                          hintText: 'Info URl',
                          labelText: 'URL',
                          icon: Icon(Icons.event_note)),
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      onSaved: (value) {
                        url = value;
                        print('URL: $url');
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
                      print('Detail: $detail');
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
                      print(eventName);
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
    print('ID-------');
    print('Current id: $profileId');
    print(id);
    if (profileId == id) {
      return true;
    } else {
      return false;
    }
  }

  isClub() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(profileId)
        .get();
    print(result.get('profileType'));
    if (result.get('profileType') == 'Club') {
      isaClub = true;
     
    } else {
      isaClub = false;
    }
  }

  Future<void> deleteUser(String id) {
    return infoEvent
        .doc(id)
        .delete()
        .then((value) => print("User Deleted:"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    isClub();
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        //bottom: ,
      ),
      backgroundColor: Color(0xFFfaf0e6),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isaClub
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
            )
          : null,
      body: StreamBuilder(
        stream: infoEvent.snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            print('You are here');
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

                                        print(documents[index].documentID);

                                        // DocumentReference ref = FirebaseFirestore.instance.doc(documents[index].documentID);
                                        //print(ref.path);
                                        deleteUser(docId);
                                      },
                                    ),
                                  ],
                                )
                              : Column(),
                        ],
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  eveID = documents[index].documentID;
                  title = documents[index]['Event'];
                  print(eveID);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetail(
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
