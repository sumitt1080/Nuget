import 'dart:io';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'user_image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;

  final void Function(
    String email,
    String password,
    String userName,
    File image,
    String profileType,
    String clubName,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  File _userImageFile;
  var _userName = '';
  String _userPassword;
  var _profileType = '';
  var _club = '';

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 40.0,
  ));

  final List<String> profile = ['Student', 'Club'];

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

     if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userImageFile,
        _profileType,
        _club.trim(),
        _isLogin,
        context,
      );
      // Use those values to send our auth request ...
    }
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  isClubSelected() {
    if (_profileType == 'Club') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if(!_isLogin) UserImagePicker(_pickedImage),
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  _isLogin
                      ? SizedBox(
                          width: 2.0,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: DropDownFormField(
                            titleText: 'Profile Type',
                            hintText: 'Please choose one',
                            value: _profileType,
                            onSaved: (value) {
                              setState(() {
                                _profileType = value;
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                _profileType = value;
                              });
                            },
                            dataSource: [
                              {
                                "display": "Student",
                                "value": "Student",
                              },
                              {
                                "display": "Club",
                                "value": "Club",
                              },
                            ],
                            textField: 'display',
                            valueField: 'value',
                          ),
                        ),
                  isClubSelected()
                      ? TextFormField(
                          key: ValueKey('organisation'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 4) {
                              return 'Please enter at least 4 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'Club Name'),
                          onSaved: (value) {
                            _club = value;
                          },
                        )
                      : SizedBox(
                          height: 1.0,
                        ),
                  SizedBox(height: 12),
                  if (widget.isLoading) slider,
                  if (!widget.isLoading)
                    RaisedButton(
                      color: Colors.blue,
                      hoverColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text(_isLogin ? 'Login' : 'Signup', style: TextStyle(color: Colors.white),),
                      onPressed: _trySubmit,
                    ),
                  if (!widget.isLoading)
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have an account',style: TextStyle(color: Colors.black),),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
