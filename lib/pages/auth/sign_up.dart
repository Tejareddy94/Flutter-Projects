import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class SignUpScreen extends StatefulWidget {
  final args;
  SignUpScreen({this.args});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _signUpForm = GlobalKey<FormState>();
  var config; //App config varaible
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  // Form Fields variables
  String _firstName;
  String _password;
  String _email;
  String _lastName;
  String dob;
  List _statesList = List();
  List _districtsList = List();
  List _constituencyList = List();
  bool foreignUser = true;
// DropDown Menu Items
  final List<DropdownMenuItem> states = [];
  final List<DropdownMenuItem> districts = [];
  final List<DropdownMenuItem> constituencies = [];
  var state;
  var district;
  var constituency;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      getStateList();
    });
    setState(() {
      foreignUser = widget.args["foreign_user"];
    });
  }

  Future signUp() async {
    loading = !loading;
    setState(() {});
    var data = {
      "phone_number": widget.args['mobile'],
      "email": widget.args['email'],
      "first_name": _firstName,
      "password": _password,
      "constituency_id": constituency,
      "last_name": _lastName,
      "dob": dob,
      "foreign_user": foreignUser,
      "country": widget.args['country']
    };
    try {
      final response = await BackendService.authPost(
          '/auth/register/', {}, data, context,
          route: '/login');
      var _data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (_data["status"] == 'OK') {
          loading = !loading;
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Thanks for Signing up",
            ),
          );
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
          });
        } else if (_data["status"] == 'bad') {
          loading = !loading;
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: _data['message'],
            ),
          );
        }
      } else {
        loading = !loading;
      }
    } on LoginException catch (e) {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: e.message,
        ),
      );
    } on SocketException catch (e) {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: e.message != null
              ? "${e.message}"
              : "Problems in Network Connectivity",
        ),
      );
    } catch (e) {
      loading = !loading;
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "something went wrong please re-try",
        ),
      );
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
      print(e);
    }
  }

  Future getStateList() async {
    try {
      final response = await BackendService.get('/auth/states/', {}, context,
          route: '/login');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        setState(() {
          _statesList = _data["data"];
          _statesList.forEach((state) {
            states.add(DropdownMenuItem(
              child: Text(state['name']),
              value: state['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getDistrictList(int stateId) async {
    try {
      final response = await BackendService.get(
          '/auth/districts/$stateId', {}, context,
          route: '/login');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _districtsList = _data["data"];
        setState(() {
          _districtsList.forEach((district) {
            districts.add(DropdownMenuItem(
              child: Text(district['name']),
              value: district['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget nonForeginInfo() {
    return Column(children: <Widget>[
      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor,
            )),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        height: MediaQuery.of(context).size.height * 0.08,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.08),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField(
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(color: Theme.of(context).buttonColor),
            isExpanded: true,
            hint: Text(
              'State *',
              style: TextStyle(color: Theme.of(context).buttonColor),
            ),
            value: state,
            isDense: true,
            items: _statesList.map((state) {
              return DropdownMenuItem(
                  value: state['id'],
                  child: Text(
                    state['name'],
                    style:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ));
            }).toList(),
            validator: (value) => value == null ? 'select state' : null,
            onChanged: (val) {
              setState(() {
                state = val;
                district = null;
                constituency = null;
              });
              getDistrictList(state);
            },
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor,
            )),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        height: MediaQuery.of(context).size.height * 0.08,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.08),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField(
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(color: Theme.of(context).buttonColor),
            isExpanded: true,
            hint: Text(
              'District *',
              style: TextStyle(color: Theme.of(context).buttonColor),
            ),
            value: district,
            isDense: true,
            items: _districtsList.map((district) {
              return DropdownMenuItem(
                  value: district['id'],
                  child: Text(
                    district['name'],
                    style:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ));
            }).toList(),
            validator: (value) => value == null ? 'select district' : null,
            onChanged: (val) {
              setState(() {
                district = val;
                constituency = null;
              });
              getConstituencyList(district);
            },
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor,
            )),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        height: MediaQuery.of(context).size.height * 0.08,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.08),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField(
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(color: Theme.of(context).buttonColor),
            isExpanded: true,
            hint: Text(
              'Constituency *',
              style: TextStyle(color: Theme.of(context).buttonColor),
            ),
            validator: (value) => value == null ? 'select constituency' : null,
            value: constituency,
            isDense: true,
            items: _constituencyList.map((constituency) {
              return DropdownMenuItem(
                value: constituency['id'],
                child: Text(
                  constituency['name'],
                  style: TextStyle(color: Theme.of(context).textSelectionColor),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                constituency = val;
              });
            },
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.03)
    ]);
  }

  Future getConstituencyList(int districtId) async {
    try {
      final response = await BackendService.get(
          '/auth/constituencies/$districtId', {}, context,
          route: '/login');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _constituencyList = _data["data"];
        setState(() {
          _constituencyList.forEach((constituency) {
            districts.add(DropdownMenuItem(
              child: Text(constituency['name']),
              value: constituency['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    DateTime newDate = DateTime(date.year - 20, date.month, date.day);
    config = AppConfig.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).appBarTheme.color,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textSelectionColor,
                            fontSize: 30),
                      ),
                    ],
                  ),
                  Form(
                    key: _signUpForm,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.08),
                          child: TextFormField(
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Theme.of(context).buttonColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).buttonColor),
                                ),
                                border: OutlineInputBorder(),
                                hintText: "First Name",
                                hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor)),
                            keyboardType: TextInputType.text,
                            validator: (String value) {
                              if (!(value.length >= 3)) {
                                return 'First name is too short';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _firstName = value;
                            },
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.08),
                          child: TextFormField(
                            style: TextStyle(
                                color: Theme.of(context).textSelectionColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).buttonColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Last Name",
                              hintStyle: TextStyle(
                                color: Theme.of(context).buttonColor,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (String value) {
                              if (!(value.length > 0)) {
                                return 'Last name is Mandatory';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _lastName = value;
                            },
                          ),
                        ),
                        foreignUser
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03)
                            : nonForeginInfo(),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.08),
                          child: GestureDetector(
                            onTap: () async {
                              DateTime newDateTime =
                                  await showRoundedDatePicker(
                                context: context,
                                initialDate: newDate,
                                firstDate: DateTime(1950),
                                lastDate: newDate,
                                theme: ThemeData.dark(),
                              );
                              if (newDateTime != null) {
                                setState(() {
                                  dob = DateFormat('yyyy-MM-dd')
                                      .format(newDateTime);
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.perm_contact_calendar,
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).buttonColor),
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: "Date Of Birth",
                                  labelText: 'Date of Birth',
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).buttonColor),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                                controller: TextEditingController(text: dob),
                                style: TextStyle(
                                  color: Theme.of(context).textSelectionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.08),
                          child: TextFormField(
                            controller: _pass,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).buttonColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Theme.of(context).buttonColor,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (String value) {
                              if (!(value.length > 4)) {
                                return 'Password is too short';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _password = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 32),
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).buttonColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(
                                color: Theme.of(context).buttonColor,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            controller: _confirmPass,
                            validator: (String value) {
                              if (!(value.length > 4)) {
                                return 'Password is too short';
                              }
                              if (value != _pass.text) {
                                return 'Passwords do not Match';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _password = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.08),
                          child: RaisedButton(
                            disabledColor: Color(0xFF878787),
                            disabledTextColor: Colors.blueGrey,
                            elevation: 7.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment(0.0, 0.0),
                              child: Center(
                                child: Container(
                                  child: loading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF62C0B6)),
                                        )
                                      : Text(
                                          "SIGN UP",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                ),
                              ),
                            ),
                            color: Theme.of(context).buttonColor,
                            onPressed: loading
                                ? null
                                : () {
                                    if (_signUpForm.currentState.validate()) {
                                      _signUpForm.currentState.save();
                                      signUp();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
