import 'dart:async';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../models/profilemodal.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String username;
  String profileType;
  String _myActivity;
  String _myActivityResult;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController usernameCnt = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileType = '';
    _myActivityResult = '';
  }

  // submit() {
  //   final form = _formKey.currentState;

  //   ProfileModal profile =
  //       new ProfileModal(username: username, profiletype: profileType);
  //   print('--@--@--@');
  //   print(profile.profiletype);
  //   print('########submit');
  //   print(username);
  //   if (form.validate()) {
  //     form.save();
  //     SnackBar snackbar =
  //         SnackBar(content: Text("Welcome ${profile.username}"));
  //     _scaffoldKey.currentState.showSnackBar(snackbar);
  //     Timer(Duration(seconds: 2), () {
  //       Navigator.of(context).pop(profile);
  //     });
  //   }
  // }

  submit() {
    _formKey.currentState.save();
    ProfileModal profile =
         new ProfileModal(username: username, profiletype: profileType);
    Navigator.of(context).pop(profile);
  }


  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: "Set up your profile"),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: DropDownFormField(
                      titleText: 'Profile Type',
                      hintText: 'Choose Type',
                      value: profileType,
                      onSaved: (value) {
                        setState(() {
                          profileType = value;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          profileType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select Profile Type";
                        }
                      },
                      dataSource: [
                        {
                          "display": "Student",
                          "value": "Student",
                        },
                        {
                          "display": "Club",
                          "value": "Club",
                        }
                      ],
                      textField: 'display',
                      valueField: 'value',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
