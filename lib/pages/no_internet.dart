import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/shared/connectivity_status.dart';

class NoInternet extends StatefulWidget {
  NoInternet({Key key, this.route}) : super(key: key);
  final route;

  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  var isInternet = false;
  didChangeDependencies() {
    super.didChangeDependencies();
    final connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus.toString() != 'ConnectivityStatus.Offline') {
      isInternet = true;
    } else {
      isInternet = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isInternet ? true : false,
      child: Scaffold(
          body: Container(
              child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isInternet == true
                ? Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.green,
                    size: 50.0,
                  )
                : Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                    size: 50.0,
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            isInternet == true
                ? Column(
                    children: <Widget>[
                      Text(
                        'Yay! now you are Connected',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Image.asset('assets/images/connected.png'),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Text(
                        ' Whoops! No Internet',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Image.asset('assets/images/no-connected.png'),
                    ],
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            isInternet == true
                ? OutlineButton(
                    textColor: Colors.orange,
                    borderSide: BorderSide(color: Colors.white24),
                    color: Colors.white,
                    highlightedBorderColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, widget.route);
                    },
                    child: Text(
                      "Retry",
                    ),
                  )
                : Text(''),
          ],
        ),
      ))),
    );
  }
}
