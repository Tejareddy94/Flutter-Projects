import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
          appBar: AppBar(
            title: Text("Settings"),
          ),
          body: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.color_lens,
                    color: Theme.of(context).iconTheme.color),
                title: Text(
                  'Theme',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                onTap: () {
                  Provider.of<ThemeModel>(context).toggleTheme();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'About App',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: Image.asset('assets/images/logomin.png'),
                      applicationVersion: "1.0.1",
                      applicationName: "Right2Ask");
                },
              ),
            ],
          )),
    );
  }
}
