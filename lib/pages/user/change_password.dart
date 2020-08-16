import 'package:flutter/material.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key, this.bearer});
  final bearer;
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPass = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  var _oldPassword, _newPassword, _confirmPassword;
  bool _loading = false;

  validateForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      saveForm();
    }
  }

  saveForm() async {
    setState(() {
      _loading = true;
    });
    final response = await BackendService.put(
        '/auth/change_password/',
        {HttpHeaders.authorizationHeader: "Bearer " + widget.bearer},
        {'old_password': _oldPassword, 'new_password': _newPassword},
        context);
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (_) {
          return CustomAlertRoundedBox(
            message: "Password Changed Successfully",
          );
        },
      );
      _currentPass.clear();
      _pass.clear();
      _confirmPass.clear();
    } else if (response.statusCode == 400) {
      setState(() {
        _loading = false;
      });
      var _data = jsonDecode(response.body);
      if (_data['old_password'] != null) {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "You have Entered Wrong Password please try again",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Loading()
          : Stack(children: <Widget>[
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.04,
                      // ),
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Column(
                            children: <Widget>[
                              // Text(
                              //   "Reset Password",
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.bold,
                              //       color: Theme.of(context).textTheme.bodyText1.color,
                              //       fontSize: 30),
                              // ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              TextFormField(
                                controller: _currentPass,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: "Current Password",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (String value) {
                                  if (!(value.length > 0)) {
                                    return 'Password Cannot be empty';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    _oldPassword = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              TextFormField(
                                controller: _pass,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: "New Password",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (String value) {
                                  if (!(value.length > 7)) {
                                    return 'Password is too short';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    _newPassword = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              TextFormField(
                                controller: _confirmPass,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: "Repeat New Password",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (String value) {
                                  if (value != _pass.text) {
                                    return 'Passwords Does not match';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    _confirmPassword = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.08),
                                child: RaisedButton(
                                    disabledColor: Colors.blueGrey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      alignment: Alignment(0.0, 0.0),
                                      child: Center(
                                        child: Container(
                                          child: _loading
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Color(0xFF62C0B6)),
                                                )
                                              : Text(
                                                  'Reset Password',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                        ),
                                      ),
                                    ),
                                    color: Theme.of(context).buttonColor,
                                    onPressed: () {
                                      validateForm();
                                    }),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
      appBar: AppBar(
        title: Text('Reset Password'),
        elevation: 0.0,
      ),
    );
  }
}
