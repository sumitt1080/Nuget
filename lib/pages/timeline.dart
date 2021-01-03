import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:nuget/pages/personalEventInfo.dart';
import 'package:shifting_tabbar/shifting_tabbar.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import '../widgets/header.dart' as head;

import 'dart:convert';
import 'EventDetail.dart';
import '../widgets/post.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with TickerProviderStateMixin {
  CollectionReference eventref = FirebaseFirestore.instance.collection('event');
  CollectionReference perevent =
      FirebaseFirestore.instance.collection('privateEvent');

  final GlobalKey _refreshIndicatorKey = GlobalKey();
  String profileId;
  String eveID;
  String title;
  String date;

  final detailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String eventName;
  String organiser;
  String detail;
  String venue;
  bool _isLoading = false;

  String _valueChanged1 = '';
  String _valueToValidate1 = '';
  String _valueSaved1 = '';
//  DateTime _valueSaved1 = null;
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  TextEditingController _controller5;
  TextEditingController _controller1;

  @override
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

  Animation<double> _animation;
  AnimationController _animationController;

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

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

  Future<void> deleteUser(int marker, String id) {
    if (marker == 1) {
      return eventref
          .doc(id)
          .delete()
          .then((value) => print("User Deleted:"))
          .catchError((error) => print("Failed to delete user: $error"));
    } else {
      perevent
          .doc(id)
          .delete()
          .then((value) => print("User Deleted:"))
          .catchError((error) => print("Failed to delete user: $error"));
    }
  }

  Future<void> submit() async {
    _formKey.currentState.save();

    //final dur = Duration(days: day, hours: hour, minutes: minute);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('privateEvent').doc()
          // .collection('post')
          // .doc()
          .set({
        'TimeStamp': Timestamp.now(),
        'Event': eventName,
        'Description': detail,
        'Venue': venue,
        'Date': _valueSaved1,
        'Start Time': _valueSaved2,
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
                    decoration: const InputDecoration(
                        hintText: 'Where\'s the Event',
                        labelText: 'Venue',
                        icon: Icon(Icons.add_location)),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onSaved: (value) {
                      venue = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter Description',
                      icon: Icon(Icons.description),
                    ),
                    controller: detailController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 2,
                    onSubmitted: (value) {
                      print('Detail: $detail');
                      detail = value;
                    },
                    onChanged: (value) {
                      detail = value;
                    },
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.date,
                    dateMask: 'd MMM, yyyy',
                    controller: _controller1,
                    //initialValue: _initialValue,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    icon: Icon(Icons.event),
                    dateLabelText: 'Date',

                    onChanged: (val) => setState(() => _valueChanged1 = val),
                    validator: (val) {
                      setState(() => _valueToValidate1 = val);
                      return null;
                    },
                    onSaved: (val) => setState(() => _valueSaved1 = val),
                    textInputAction: TextInputAction.next,
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.time,
                    controller: _controller5,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.access_time),
                    timeLabelText: "Time",
                    //use24HourFormat: false,
                    //locale: Locale('en', 'US'),
                    onChanged: (val) => setState(() => _valueChanged2 = val),
                    validator: (val) {
                      setState(() => _valueToValidate2 = val);
                      return null;
                    },
                    onSaved: (val) => setState(() => _valueSaved2 = val),
                    textInputAction: TextInputAction.next,
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

  @override
  Widget build(context) {
    //getEvents();
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: SizedBox(),
                title: Text('Timeline'),
                bottom: TabBar(
          tabs: [
            Tab(
            text: 'All Event',
            //icon: Icon(LineAwesomeIcons.list)
            ),
            Tab(
            text: 'Your Remainder',
           // icon: Icon(LineAwesomeIcons.adjust)
            )
          ],
                    ),
              ),
          backgroundColor: Color(0xFFfaf0e6),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionBubble(
            animation: _animation,
            items: [
              Bubble(
                title: "Add Personal Event",
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
          ),
          body: TabBarView(
            children: [
              StreamBuilder(
                stream: eventref.orderBy('Date', descending: true).snapshots(),
                builder: (ctx, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        'On ${documents[index]['Date']} At ${documents[index]['Start Time']}',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w300),
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

                                                print(documents[index]
                                                    .documentID);

                                                // DocumentReference ref = FirebaseFirestore.instance.doc(documents[index].documentID);
                                                //print(ref.path);
                                                deleteUser(1, docId);
                                              },
                                            ),
                                          ],
                                        )
                                      : Column(),
                                  Column(
                                    children: [
                                      Icon(Icons.notifications_active)
                                    ],
                                  )
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
                                    eveId: eveID,
                                    title: title,
                                  )));
                        },
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder(
                stream: perevent
                    .orderBy('Date', descending: true)
                    .where('Owner', isEqualTo: profileId.toString())
                    .snapshots(),
                builder: (ctx, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    print('You are here');
                    return Center(
                      child: slider,
                    );
                  }
                  if (streamSnapshot.hasError) {
                    return Center(
                      child: slider,
                    );
                  }
                  if (!streamSnapshot.hasData) {
                    return Center(
                      child: Text(
                        'No Personal events',
                        style: TextStyle(fontSize: 24),
                      ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      // Text(
                                      //   documents[index]['Organiser'],
                                      //   style: TextStyle(
                                      //       fontSize: 20.0,
                                      //       fontWeight: FontWeight.w400),
                                      // ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        'On ${documents[index]['Date']} At ${documents[index]['Start Time']}',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  Column(
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
                                          deleteUser(2, docId);
                                        },
                                      ),
                                    ],
                                  )
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
                              builder: (context) => PersonalEventInfo(
                                    eveId: documents[index].documentID,
                                    title: documents[index]['Event'],
                                  )));
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
