import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'dart:convert';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class OtpLogin extends StatefulWidget {
  @override
  _OtpLoginState createState() => _OtpLoginState();
}

class _OtpLoginState extends State<OtpLogin> {
  final _generateFormKey = GlobalKey<FormState>();
  final _validateFormKey = GlobalKey<FormState>();
  var config;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _phoneNumber;
  String _otp;
  bool _resend = false;
  Timer _timer;
  int _start;
  int counter = 0;

  TextEditingController _pinEditingController = TextEditingController(text: '');
  bool _enable = true;
  bool _hasError = false;
  bool _visblePhone = true;
  bool _visbleOTP = false;
  bool _loading = false;
  bool _disabled = false;
  final storage = new FlutterSecureStorage();

  final GlobalKey<FormFieldState<String>> _formKey =
      GlobalKey<FormFieldState<String>>(debugLabel: '_formkey');

  String validatePhone(String value) {
    Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Number';
    else
      return null;
  }

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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void validateNumber() {
    if (_generateFormKey.currentState.validate()) {
      _generateFormKey.currentState.save();
      generateOtpLogin();
    }
  }

  Future generateOtpLogin() async {
    setState(() => _loading = true);

    var data = {
      "phone_number": _phoneNumber,
    };
    try {
      final response = await BackendService.authPost(
          '/auth/generate_login_otp/', {}, data, context,
          route: '/otplogin');
      var _data = jsonDecode(response.body);
      if (_data["status"] == 'ok') {
        startTimer();
        setState(() {
          _loading = false;
          _disabled = false;
          _visbleOTP = !_visbleOTP;
          _visblePhone = !_visblePhone;
        });
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
        setState(() => _loading = false);
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
      setState(() => _loading = false);
      print(e);
    }
  }

  Future resendOTP() async {
    if (counter < 5) {
      setState(() => _resend = !_resend);
      var data = {
        "phone_number": _phoneNumber,
      };
      try {
        final response = await BackendService.authPost(
            '/auth/generate_login_otp/', {}, data, context,
            route: '/otplogin');
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
          message: "Your OTP Limit has been exceeded \n Try again later",
        ),
      );
    }
  }

  Future validateLoginOtp() async {
    setState(() {
      _loading = true;
      _disabled = false;
    });
    var data = {
      "phone_number": _phoneNumber,
      "otp": _otp,
    };
    try {
      final response = await BackendService.authPost(
          '/auth/otp_login/', {}, data, context,
          route: '/otplogin');
      var _data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await storage.write(key: 'Bearer', value: _data["access"]);
        _loading = false;
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/mainpage', (Route<dynamic> route) => false);
      } else if (response.statusCode == 401) {
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
          _disabled = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Somerthing went wrong",
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
      setState(() {
        _loading = false;
        _disabled = false;
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      Text(
                        "Login with OTP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                                errorStyle: TextStyle(fontSize: 16),
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
                              "We will send OTP to Login",
                              style:
                                  TextStyle(fontSize: 15, color: Theme.of(context).textSelectionColor),
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
                              disabledColor: Color(0xFF878787),
                              disabledTextColor: Colors.blueGrey,
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
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                         Theme.of(context).primaryColor),
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
                              onPressed: _loading ? null : validateNumber,
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
                                enteredColor: Colors.green,
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
                                        color: Theme.of(context).textSelectionColor, fontSize: 18),
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
                                        validateLoginOtp();
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
