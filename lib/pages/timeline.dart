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

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Timeline extends StatefulWidget {
  Timeline({this.map, this.type});
  Map<String, dynamic> map;
  String type;
  @override
  _TimelineState createState() => _TimelineState(map: map, ptype: type);
}

class _TimelineState extends State<Timeline> with TickerProviderStateMixin {
  _TimelineState({this.map, this.ptype});
  Map<String, dynamic> map;
  String ptype;

  CollectionReference eventref = FirebaseFirestore.instance.collection('event');
  CollectionReference perevent =
      FirebaseFirestore.instance.collection('privateEvent');
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

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

  List<String> list = new List();

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

  void mapToList() {
    if (map == null) {
      return;
    }
    map.forEach((key, value) {
      if (value.toString() == 'true') {
        list.add(key);
      }
    });
  }

  bool isOwner(String id) {
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
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('privateEvent').doc().set({
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

  containID(String cardID) {
    if (list.contains(cardID)) {
      return true;
    } else {
      return false;
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
                    firstDate: DateTime.now(),
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
                    icon: Icon(Icons.access_time),
                    timeLabelText: "Time",
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

  isClub() {
    if (ptype == 'Club') {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(context) {
    mapToList();
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
                ),
                Tab(
                  text: 'Your Remainder',
                  
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
              isClub()
                  ? (StreamBuilder(
                      stream: eventref
                          .where('Owner', isEqualTo: profileId)
                          .snapshots(),
                      builder: (ctx, streamSnapshot) {
                        if (streamSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: slider,
                          );
                        }
                        final documents = streamSnapshot.data.documents;
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
                                                        documents[index]
                                                            .documentID;

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
                              )),
                              onTap: () {
                                eveID = documents[index].documentID;
                                title = documents[index]['Event'];
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
                    ))
                  : (list.isEmpty
                      ? Center(
                          child: Text('Not Subscribed To any Club'),
                        )
                      : StreamBuilder(
                          stream: eventref
                              .orderBy('Date', descending: true)
                              .snapshots(),
                          builder: (ctx, streamSnapshot) {
                            if (streamSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: slider,
                              );
                            }

                            final documents = streamSnapshot.data.documents;
                           

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (ctx, index) => Container(
                                padding: EdgeInsets.all(5),
                                child: GestureDetector(
                                  child: InkWell(
                                      child: containID(
                                              documents[index]['Owner'])
                                          ? Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              shadowColor: Color(0xFF848482),
                                              elevation: 10.0,
                                              child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          documents[index]
                                                              ['Event'],
                                                          style: TextStyle(
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          documents[index]
                                                              ['Organiser'],
                                                          style: TextStyle(
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          'On ${documents[index]['Date']} At ${documents[index]['Start Time']}',
                                                          style: TextStyle(
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ],
                                                    ),
                                                    isOwner(documents[index]
                                                            ['Owner'])
                                                        ? Column(
                                                            children: [
                                                              FlatButton(
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onPressed: () {
                                                                  String docId =
                                                                      documents[
                                                                              index]
                                                                          .documentID;

                                                                  deleteUser(
                                                                      1, docId);
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                        : Column(),
                                                    Column(
                                                      children: [
                                                        Icon(Icons
                                                            .notifications_active)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox()),
                                  onTap: () {
                                    eveID = documents[index].documentID;
                                    title = documents[index]['Event'];
                                    
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => EventDetail(
                                                  eveId: eveID,
                                                  title: title,
                                                )));
                                  },
                                ),
                              ),
                            );
                          },
                        )),
              StreamBuilder(
                stream: perevent
                    .orderBy('Date', descending: true)
                    .where('Owner', isEqualTo: profileId.toString())
                    .snapshots(),
                builder: (ctx, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
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
