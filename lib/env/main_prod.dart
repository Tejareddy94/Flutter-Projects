import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/main.dart';
import 'package:flutter/material.dart';

void main() {
  var configuredApp = new AppConfig(
    appName: 'Right To Ask',
    envMode: 'production',
    baseUrl: 'http://18.216.215.58',
    child: new MyApp(),
  );

  runApp(configuredApp);
}