import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/main.dart';
import 'package:flutter/material.dart';

void main() {
  var configuredApp = new AppConfig(
    appName: 'Right To Ask - dev',
    envMode: 'development',
    baseUrl: 'http://api.right2ask.com',
    child:  MyApp(),
  );
  runApp(configuredApp);
}