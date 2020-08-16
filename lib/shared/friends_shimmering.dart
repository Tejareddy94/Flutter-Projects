import 'package:flutter/material.dart';
class FriendsShimmering extends StatefulWidget {
  const FriendsShimmering({
    Key key,
  }) : super(key: key);
  @override
  _FriendsShimmeringState createState() => _FriendsShimmeringState();
}

class _FriendsShimmeringState extends State<FriendsShimmering>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1400), vsync: this);
    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).accentColor == Colors.black
        ? [Colors.white12, Colors.white24, Colors.white12]
        : [Colors.black12, Colors.black26, Colors.black12];
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(context).accentColor,
                        gradient: LinearGradient(
                            begin: Alignment(gradientPosition.value, 0),
                            end: Alignment(1, 0),
                            colors: colors)),
                    height: MediaQuery.of(context).size.width * 0.12,
                    width: MediaQuery.of(context).size.width * 0.12,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        // margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height * 0.01,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment(gradientPosition.value, 0),
                                end: Alignment(1, 0),
                                colors: colors)),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        // margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height * 0.01,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment(gradientPosition.value, 0),
                                end: Alignment(1, 0),
                                colors: colors)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
