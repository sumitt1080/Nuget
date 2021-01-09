//import 'dart:html';

//import 'dart:html';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:duration/duration.dart';
import '../widgets/header.dart' as head;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:date_time_picker/date_time_picker.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
final uid = user.uid;

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _controller2;
  TextEditingController _controller3;
  TextEditingController _controller4;
  TextEditingController _controller1;
  TextEditingController _controller5;
  String _valueChanged1 = '';
  String _valueToValidate1 = '';
  String _valueSaved1 = '';
//  DateTime _valueSaved1 = null;
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  // DateTime _valueSaved2 =null ;
  final detailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  

  String eventName;
  String organiser;
  String detail;
  String venue;
  DateTime date;
  TimeOfDay time1;
  int day, hour, minute;
  bool _isLoading = false;

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  String pid;

  @override
  void initState() {
    _controller2 = TextEditingController(text: DateTime.now().toString());
    _controller3 = TextEditingController(text: DateTime.now().toString());
    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    _controller4 = TextEditingController(text: '$lsHour:$lsMinute');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user = auth.currentUser;
      pid = uid;
    });
  }

  @override
  void dispose() {
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    _formKey.currentState.save();
    
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('event').doc()
          // .collection('post')
          // .doc()
          .set({
        'TimeStamp': Timestamp.now(),
        'Event': eventName,
        'Organiser': organiser,
        'Description': detail,
        'Venue': venue,
        'Date': _valueSaved1,
        'Start Time': _valueSaved2,
        'Owner': pid,
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

  _fetchClub() async {
    DocumentSnapshot result =
        await FirebaseFirestore.instance.collection('users').doc(pid).get();
    organiser = result.data()['club'];
  }

  Container buildSplashScreen(double width) {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "Add Event",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                  color: Colors.deepOrange,
                  onPressed: () {
                    showModalBottomSheet<void>(
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
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                          10,
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
                                    onEditingComplete: () =>
                                        FocusScope.of(context).nextFocus(),
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
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    icon: Icon(Icons.event),
                                    dateLabelText: 'Date',

                                    onChanged: (val) =>
                                        setState(() => _valueChanged1 = val),
                                    validator: (val) {
                                      setState(() => _valueToValidate1 = val);
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        setState(() => _valueSaved1 = val),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  DateTimePicker(
                                    type: DateTimePickerType.time,
                                    controller: _controller5,
                                    icon: Icon(Icons.access_time),
                                    timeLabelText: "Time",
                                    onChanged: (val) =>
                                        setState(() => _valueChanged2 = val),
                                    validator: (val) {
                                      setState(() => _valueToValidate2 = val);
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        setState(() => _valueSaved2 = val),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  RaisedButton(
                                    child: _isLoading ? slider : Text('Submit'),
                                    color: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      submit();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _fetchClub();
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:
          head.header(context, isAppTitle: false, titleText: 'Upload Event'),
      body: buildSplashScreen(width),
    );
  }
}
