//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _controller2;
  TextEditingController _controller3;
  TextEditingController _controller4;

  @override
  void initState() {
    _controller2 = TextEditingController(text: DateTime.now().toString());
    _controller3 = TextEditingController(text: DateTime.now().toString());
    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    _controller4 = TextEditingController(text: '$lsHour:$lsMinute');
  }

 Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
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
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                         // Padding(
                            //padding: EdgeInsets.all(8.0),
                             TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Event Name',
                                labelText: 'Event',
                                icon: Icon(Icons.details)
                              ),
                              
                            ),
                         // ),
                         TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Who\'s the Organiser',
                                labelText: 'Organiser',
                                icon: Icon(Icons.details)
                              ),
                            ),
                            TextField(
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 2,
                            ),
                          DateTimePicker(
                            type: DateTimePickerType.dateTime,
                            dateMask: 'yyyy/MM/dd',
                            controller: _controller3,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            icon: Icon(Icons.event),
                            dateLabelText: 'Date',
                          ),
                          DateTimePicker(
                            type: DateTimePickerType.time,
                            controller: _controller4,
                            //initialValue: _initialValue,
                            icon: Icon(Icons.access_time),
                            timeLabelText: "Time",
                            //use24HourFormat: false,
                            //locale: Locale('en', 'US'),
                          ),
                        ],
                      ),
                    );
                  });
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen();
  }
}
