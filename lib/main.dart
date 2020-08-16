import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/router/routes.dart';
import 'package:r2a_mobile/service/connectivity_service.dart';
import 'package:r2a_mobile/shared/connectivity_status.dart';
import 'package:r2a_mobile/shared_state/call_ringtone_state.dart';
import 'package:r2a_mobile/shared_state/call_screen.dart';
import 'shared_state/user.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    var config = AppConfig.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserState(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchResultsState(),
        ),
        ChangeNotifierProvider(
          create: (context) => SentFriendRequestState(),
        ),
        ChangeNotifierProvider(
          create: (context) => FriendsListState(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReceivedFriendRequestState(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CallScreenState(),
        ),
        ChangeNotifierProvider(
          create : (context) => TimerCounterState(),
        ),
        ChangeNotifierProvider(
          create : (context) => CallRingToneState(),
        ),
      ],
      child: StreamProvider<ConnectivityStatus>(
        create: (context) =>
            ConnectivityService().connectionStatusController.stream,
        child: Consumer<ThemeModel>(
          builder: (context, themeData, child) {
            return MaterialApp(
              title: config.appName,
              debugShowCheckedModeBanner: false,
              theme: Provider.of<ThemeModel>(context).currentTheme,
              // initialRoute: '/',
              onGenerateRoute: Router.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
