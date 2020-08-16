import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  final storage = new FlutterSecureStorage();
  UserState userState;
  ThemeModel themeData;
  String avatar,
      profileName,
      email,
      phoneNumber,
      userRole,
      bearer,
      canCreate,
      userId,
      pushToken,
      foreignUser,
      theme;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    bearer = await storage.read(key: 'Bearer');
    if (bearer?.isEmpty ?? true) {
      await storage.deleteAll();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      getUserData().then((value) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => setProviderData(context).then((value) {}));
      });
    }
  }

  Future setProviderData(BuildContext context) async {
    userState = Provider.of<UserState>(context, listen: true);
    userState.setUserDetails(
      avatar: avatar,
      bearer: bearer,
      canCreate: canCreate,
      email: email,
      id: userId,
      name: profileName,
      phoneNumber: phoneNumber,
      role: userRole,
      foreignUser: foreignUser,
    );
    userState.updatePushToken = pushToken;
    themeData = Provider.of<ThemeModel>(context, listen: true);
    themeData.setTheme(type: theme);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/mainpage', (Route<dynamic> route) => false);
  }

  Future getUserData() async {
    avatar = await storage.read(key: 'avatar');
    profileName = await storage.read(key: 'name');
    email = await storage.read(key: 'email');
    phoneNumber = await storage.read(key: 'phoneNumber');
    userRole = await storage.read(key: 'role');
    canCreate = await storage.read(key: 'can_create');
    userId = await storage.read(key: 'userId');
    pushToken = await storage.read(key: 'push_token');
    foreignUser = await storage.read(key: 'foreign_user');
    theme = await storage.read(key: "theme");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/r2kk.gif',
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
