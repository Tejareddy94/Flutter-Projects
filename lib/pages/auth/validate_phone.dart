import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class ValidatePhone extends StatefulWidget {
  @override
  _ValidatePhoneState createState() => _ValidatePhoneState();
}

class _ValidatePhoneState extends State<ValidatePhone> {
  final _generateFormKey = GlobalKey<FormState>();
  final _validateFormKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var config;
  String _phoneNumber;
  String _email;
  int _country;
  final List<DropdownMenuItem> _countries = [];
  List _countriesList = List();
  String _otp;
  Timer _timer;
  int _start;
  int counter = 0;

  TextEditingController _pinEditingController = TextEditingController(text: '');
  bool _enable = true;
  bool _hasError = false;
  bool _visblePhone = true;
  bool _visbleOTP = false;
  bool _loading = false;
  bool _disabled = true;
  bool _resend = false;
  bool foreignUser = true;

  final GlobalKey<FormFieldState<String>> _formKey =
      GlobalKey<FormFieldState<String>>(debugLabel: '_formkey');

  void startTimer() {
    _start = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            _resend = true;
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      getCountriesList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String validatePhone(String value) {
    Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Number';
    else
      return null;
  }

  String validEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  Future getCountriesList() async {
    print('Come Here yee');
    try {
      final response = await BackendService.get('/auth/countries/', {}, context,
          route: '/login');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        print(_data["data"]);
        setState(() {
          _countriesList = _data["data"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future generateOTP() async {
    setState(() {
      _loading = true;
    });
    var data = {
      "phone_number": _phoneNumber,
      "email": _email,
      "country": _country
    };
    try {
      final response = await BackendService.authPost(
          '/auth/generate_otp/', {}, data, context,
          route: '/validate');
      var _data = jsonDecode(response.body);
      if (_data["status"] == 'ok') {
        setState(() {
          counter++;
          _loading = false;
          _disabled = false;
          _visbleOTP = !_visbleOTP;
          _visblePhone = !_visblePhone;
        });
        startTimer();
      } else if (_data["status"] == 'bad') {
        setState(() {
          _loading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: _data['msg'],
          ),
        );
      } else {
        setState(() {
          setState(() {
            _loading = false;
          });
        });
      }
    } on LoginException catch (e) {
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: e.message,
        ),
      );
    } on SocketException catch (e) {
      setState(() {
        _loading = false;
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
      print(e);
    }
  }

  Future resendOTP() async {
    if (counter < 5) {
      setState(() => _resend = !_resend);
      var data = {
        "phone_number": _phoneNumber,
        "email": _email,
        "country": _country
      };
      try {
        final response = await BackendService.authPost(
            '/auth/generate_otp/', {}, data, context,
            route: '/validate');
        var _data = jsonDecode(response.body);
        if (_data["status"] == 'ok') {
          setState(() => counter++);
          startTimer();
        } else if (_data["status"] == 'bad') {
          _resend = !_resend;
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: _data['msg'],
            ),
          );
        } else {
          _resend = !_resend;
        }
      } on LoginException catch (e) {
        setState(() {
          _loading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: e.message,
          ),
        );
      } on SocketException catch (e) {
        setState(() {
          _loading = false;
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
        print(e);
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "Your OTP Limit has been exceeded",
        ),
      );
    }
  }

  Future validateOTP() async {
    setState(() => _disabled = false);
    var data = {"phone_number": _phoneNumber, "otp": _otp, "email": _email};
    try {
      final response = await BackendService.authPost(
          '/auth/validate_phone/', {}, data, context,
          route: '/validate');
      var _data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          _disabled = true;
        });
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/signup', arguments: {
          'mobile': _phoneNumber,
          'email': _email,
          'country': _country,
          'foreign_user': foreignUser
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _hasError = true; //#TODO: Validate OTP error
          _loading = false;
          _disabled = true;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: _data["message"],
          ),
        );
      } else {
        setState(() {
          _loading = false;
          _disabled = true;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Something went Wrong. Try again later",
          ),
        );
      }
    } on LoginException catch (e) {
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: e.message,
        ),
      );
    } on SocketException catch (e) {
      setState(() {
        _loading = false;
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
      setState(() {
        _loading = false;
        _disabled = true;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "Somerthing went wrong on our End",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 15.0),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textSelectionColor),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Visibility(
                    visible: _visblePhone,
                    child: Form(
                      key: _generateFormKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.08),
                            child: TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone_android,
                                  color: Theme.of(context).buttonColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).buttonColor)),
                                border: OutlineInputBorder(),
                                hintText: "Phone Number",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: validatePhone,
                              onSaved: (String value) {
                                _phoneNumber = value;
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.08),
                            child: TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: Theme.of(context).buttonColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).buttonColor),
                                ),
                                border: OutlineInputBorder(),
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              validator: validEmail,
                              onSaved: (String value) {
                                _email = value;
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                )),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.03),
                            height: MediaQuery.of(context).size.height * 0.08,
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.08),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                style: TextStyle(
                                    color: Theme.of(context).buttonColor),
                                isExpanded: true,
                                hint: Text(
                                  'Country *',
                                  style: TextStyle(
                                      color: Theme.of(context).buttonColor),
                                ),
                                value: _country,
                                isDense: true,
                                items: _countriesList.map((country) {
                                  return DropdownMenuItem(
                                      value: country['id'],
                                      child: Text(
                                        country['name'],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textSelectionColor),
                                      ));
                                }).toList(),
                                validator: (value) =>
                                    value == null ? 'select country' : null,
                                onChanged: (val) {
                                  setState(() {
                                    _country = val;
                                  });
                                  var selectedCountry =
                                      _countriesList.firstWhere(
                                          (element) => element['id'] == val);
                                  if (selectedCountry['name']
                                          .toString()
                                          .toLowerCase() ==
                                      'india') {
                                    this.setState(() {
                                      foreignUser = false;
                                    });
                                  } else {
                                    this.setState(() {
                                      foreignUser = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Center(
                            child: Text(
                              "We will send OTP to SignUp",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).textSelectionColor),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.08),
                            child: RaisedButton(
                              disabledTextColor: Colors.blueGrey,
                              elevation: 7.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                alignment: Alignment(0.0, 0.0),
                                child: Center(
                                  child: Container(
                                    child: _loading
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF62C0B6)),
                                          )
                                        : Text(
                                            'Send OTP',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                              color: Theme.of(context).buttonColor,
                              onPressed: _loading
                                  ? null
                                  : () {
                                      if (_generateFormKey.currentState
                                          .validate()) {
                                        _generateFormKey.currentState.save();
                                        generateOTP();
                                      }
                                    },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _visbleOTP,
                    child: Form(
                      key: _validateFormKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.04),
                            child: PinInputTextFormField(
                              key: _formKey,
                              pinLength: 6,
                              decoration: BoxLooseDecoration(
                                strokeWidth: 1.0,
                                strokeColor: Theme.of(context).buttonColor,
                                enteredColor: Color(0xFF00BEAF),
                                // solidColor: Colors.white,
                                // textStyle: TextStyle(color: Colors.black),
                                obscureStyle: ObscureStyle(
                                  isTextObscure: false,
                                  obscureText: '☺️',
                                ),
                              ),
                              controller: _pinEditingController,
                              textInputAction: TextInputAction.go,
                              enabled: _enable,
                              onSubmit: (pin) {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                }
                              },
                              onChanged: (pin) {
                                if (pin.length >= 6) {
                                  setState(() {
                                    _disabled = true;
                                  });
                                } else {
                                  setState(() {
                                    _disabled = false;
                                  });
                                }
                              },
                              onSaved: (pin) {
                                _otp = pin;
                              },
                              validator: (pin) {
                                if (pin.isEmpty) {
                                  setState(() {
                                    _hasError = true;
                                  });
                                  return 'Pin cannot empty.';
                                }
                                setState(() {
                                  _hasError = false;
                                });
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.15),
                            child: _resend
                                ? Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.12),
                                    child: RaisedButton(
                                      disabledColor: Color(0xFF62C0B6),
                                      disabledTextColor: Colors.blueGrey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Resend code',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      // color: Colors.white70,
                                      onPressed: () {
                                        resendOTP();
                                      },
                                    ),
                                  )
                                : Text(
                                    "Resend SMS in  $_start",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textSelectionColor,
                                        fontSize: 18),
                                  ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.08),
                            child: RaisedButton(
                              disabledColor: Color(0xFF878787),
                              disabledTextColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                alignment: Alignment(0.0, 0.0),
                                child: Container(
                                  child: _loading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF62C0B6)),
                                        )
                                      : Text(
                                          'Verify',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                              color: Theme.of(context).buttonColor,
                              onPressed: _disabled
                                  ? () {
                                      if (_validateFormKey.currentState
                                              .validate() &&
                                          _country != null) {
                                        _validateFormKey.currentState.save();
                                        _loading = true;
                                        validateOTP();
                                      }
                                    }
                                  : null,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                        ],
                      ),
                    ),
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
