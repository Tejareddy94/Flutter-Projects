import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:r2a_mobile/shared/connectivity_snack_bar.dart';
import 'package:r2a_mobile/shared/delayed_animation.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController controller;
  Animation<double> scaleAnimation;
  final int delayedAmount = 500;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    connectivitySnackBar(context, _scaffoldKey.currentState);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  DelayedAnimation(
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                    delay: delayedAmount + 1000,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: DelayedAnimation(
                      child: Text(
                        "Connect with People",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textSelectionColor,
                        ),
                      ),
                      delay: delayedAmount + 1500,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: DelayedAnimation(
                        delay: delayedAmount + 2000,
                        child: Text(
                          "We give the ability to connect with millions of people no matter where you are.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyText2.color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              FadeTransition(
                opacity: controller,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.03),
                    child: RaisedButton(
                      // elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.06,
                        alignment: Alignment(0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'LOG IN',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      color: Theme.of(context).buttonColor,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              FadeTransition(
                opacity: controller,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.03),
                    child: RaisedButton(
                      // elevation: 10.0,
                      shape: RoundedRectangleBorder(
                         side: BorderSide(color: Theme.of(context).buttonColor,width: 2),
                          borderRadius: BorderRadius.circular(30)),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.06,
                        alignment: Alignment(0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'SIGN UP',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).buttonColor),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/validate');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
