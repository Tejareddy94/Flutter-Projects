import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/pages/Models/login_model.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var config;
  final _loginForm = GlobalKey<FormState>();
  String _password, _email;
  bool _loading = false;
  final storage = new FlutterSecureStorage();
  UserState userState;
  Future login() async {
    setState(() => _loading = !_loading);
    var data = {
      "email": _email,
      "password": _password,
    };
    try {
      final response = await BackendService.authPost(
          '/auth/email_login/', {}, data, context,
          route: '/login');
      var _data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var data = LoginModel.fromJson(_data);
        await storage.write(key: 'Bearer', value: data.access);
        await storage.write(key: 'name', value: data.userName);
        await storage.write(key: 'email', value: data.email);
        await storage.write(key: 'avatar', value: data.avatarUrl);
        await storage.write(key: 'role', value: data.role.toString());
        await storage.write(
            key: 'is_admin', value: data.isAdmin ? 'true' : 'false');
        await storage.write(key: 'phoneNumber', value: data.phoneNumber);
        await storage.write(
            key: 'can_create', value: data.canCreate ? 'true' : 'false');
        await storage.write(key: 'userId', value: data.id.toString());
        await storage.write(
            key: 'foreign_user', value: data.foreignUser ? 'true' : 'false');
        _loading = false;
        userState.setUserDetails(
            avatar: data.avatarUrl,
            bearer: data.access,
            canCreate: data.canCreate ? 'true' : 'false',
            email: data.email,
            id: data.id.toString(),
            name: data.userName,
            phoneNumber: data.phoneNumber,
            foreignUser: data.foreignUser ? 'true' : 'false',
            role: data.role.toString());
        _firebaseMessaging.getToken().then((value) async {
          Firestore.instance
              .collection("users")
              .document(data.id.toString())
              .updateData({"pushToken": value});
          await storage.write(key: 'push_token', value: value);
          userState.updatePushToken = value;
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/mainpage', (Route<dynamic> route) => false);
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _loading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: _data['detail'],
          ),
        );
      } else {
        _loading = false;
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "something went Wrong",
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
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "something went Wrong on our end",
        ),
      );
      print(e);
    }
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

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    config = AppConfig.of(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).appBarTheme.color,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Text(
                    "Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textSelectionColor,
                        fontSize: 30),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Form(
                key: _loginForm,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.01,
                          horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
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
                        keyboardType: TextInputType.emailAddress,
                        validator: validEmail,
                        onSaved: (String value) {
                          _email = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.01,
                          horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).buttonColor,
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
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.06,
                          alignment: Alignment(0.0, 0.0),
                          child: Center(
                            child: Container(
                              child: _loading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                        onPressed: _loading
                            ? null
                            : () {
                                if (_loginForm.currentState.validate()) {
                                  _loginForm.currentState.save();
                                  login();
                                }
                              },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/forgotpassword');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  // height: MediaQuery.of(context).size.height * 0.08,
                  color: Colors.transparent,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Forgot password ?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).textTheme.bodyText2.color,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/otplogin');
                },
                child: Center(
                  child: Text(
                    "Login with OTP instead",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).textTheme.bodyText2.color,
                        fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
