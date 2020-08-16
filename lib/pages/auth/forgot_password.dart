import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'dart:convert';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _generateFormKey = GlobalKey<FormState>();
  final _validateFormKey = GlobalKey<FormState>();
  var config;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _phoneNumber;
  String _otp;
  String _password;
  Timer _timer;
  int _start = 30;
  int counter = 0;

  TextEditingController _pinEditingController = TextEditingController(text: '');
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  bool _enable = true;
  bool _hasError = false;
  bool _visblePhone = true;
  bool _visbleOTP = false;
  bool _loading = false;
  bool _disabled = false;
  bool _resend = false;

  final GlobalKey<FormFieldState<String>> _formKey =
      GlobalKey<FormFieldState<String>>(debugLabel: '_formkey');

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            _resend = true;
            timer.cancel();
          } else {
            setState(() => _start = _start - 1);
          }
        },
      ),
    );
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

  Future forgotPasswordOtp() async {
    setState(() {
      _loading = true;
    });
    var data = {
      "phone_number": _phoneNumber,
    };
    try {
      final response = await BackendService.authPost(
          '/auth/forgot_password_otp/', {}, data, context,
          route: '/forgotpassword');

      var _data = jsonDecode(response.body);
      if (_data["status"] == 'ok') {
        setState(() {
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
            message: _data["message"],
          ),
        );
      } else {
        setState(() {
          _loading = false;
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
      setState(() {
        _loading = false;
      });
      print(e);
    }
  }

  Future resendOTP() async {
    if (this.mounted) {
      setState(() => _resend = !_resend);
    }
    var data = {
      "phone_number": _phoneNumber,
    };
    try {
      final response = await BackendService.authPost(
          '/auth/forgot_password_otp/', {}, data, context,
          route: '/forgotpassword');
      var _data = jsonDecode(response.body);
      if (_data["status"] == 'ok') {
        counter++;
        startTimer();
      } else if (_data["status"] == 'bad') {
        _resend = !_resend;
        _loading = !_loading;
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: _data["msg"],
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
  }

  Future resetPassword() async {
    _disabled = !_disabled;
    _loading = !_loading;
    var data = {
      "phone_number": _phoneNumber,
      "otp": _otp,
      "password": _password
    };
    try {
      final response = await BackendService.authPost(
          '/auth/reset_password/', {}, data, context,
          route: '/forgotpassword');
      var _data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _loading = false;
        if (_data["status"] == "ok") {
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: _data["message"],
            ),
          );
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
          });
        } else if (_data["status"] == 'bad') {
          _loading = false;
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: _data["message"],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: _data["message"],
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
      print(e);
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
                        "Forgot Password",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textSelectionColor),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
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
                                    MediaQuery.of(context).size.width * 0.06),
                            child: TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone_android,
                                  color: Theme.of(context).buttonColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).buttonColor),
                                ),
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
                          Center(
                            child: Text(
                              "We will send OTP to Reset your password",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.07),
                            child: RaisedButton(
                              disabledColor: Colors.blueGrey,
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
                                        forgotPasswordOtp();
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
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: PinInputTextFormField(
                              key: _formKey,
                              pinLength: 6,
                              decoration: BoxLooseDecoration(
                                strokeWidth: 1.0,
                                strokeColor: Theme.of(context).buttonColor,
                                enteredColor: Color(0xFF00BEAF),
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
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: _resend
                                ? Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.12),
                                    child: RaisedButton(
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
                                                color: Theme.of(context)
                                                    .buttonColor),
                                          ),
                                        ],
                                      ),
                                      color: Colors.white70,
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
                            height: MediaQuery.of(context).size.height * 0.05,
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
                                hintText: "New Password",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              controller: _pass,
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
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: RaisedButton(
                              disabledTextColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.06,
                                alignment: Alignment(0.0, 0.0),
                                child: Container(
                                  child: _loading
                                      ? CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                         Theme.of(context).primaryColor),
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
                                          .validate()) {
                                        _validateFormKey.currentState.save();
                                        resetPassword();
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
