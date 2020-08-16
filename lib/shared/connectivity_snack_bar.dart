import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/shared/connectivity_status.dart';

Future<void> connectivitySnackBar(context, scaffoldCurrentState) async {
    final connectionStatus = Provider.of<ConnectivityStatus>(context);
    final snackBar = SnackBar(
      content: Text(
        'No Internet',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      duration: Duration(hours: 1),
      backgroundColor: Colors.red,
    );
    if (connectionStatus.toString() == 'ConnectivityStatus.Offline' && scaffoldCurrentState != null) {
      scaffoldCurrentState.showSnackBar(snackBar);
    } else if (scaffoldCurrentState != null) {
      scaffoldCurrentState.removeCurrentSnackBar();
    }
  }