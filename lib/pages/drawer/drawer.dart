import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/user_model.dart';
import 'package:r2a_mobile/pages/friend/friends.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class CustomDrawer extends StatelessWidget {
  final storage = new FlutterSecureStorage();
  final UserDetails user;
  UserState userState;

  CustomDrawer({Key key, this.user}) : super(key: key);
  void logoutApplication() async {
    FirebaseMessaging().deleteInstanceID();
    await storage.deleteAll();
    userState.setUserDetails(
        name: "",
        avatar: "",
        bearer: "",
        phoneNumber: "",
        canCreate: "",
        email: "",
        id: "",
        role: "");
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: Theme.of(context).backgroundColor,
              alignment: Alignment.center,
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height * 0.12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  userState.avatar != null
                      ? Flexible(
                          fit: FlexFit.loose,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(userState.avatar),
                          ),
                        )
                      : Flexible(
                          fit: FlexFit.loose,
                          child: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userState.userName,
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textSelectionColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Text(
                          userState.email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textSelectionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.015,
            ),
            ListTile(
              leading: Icon(
                Icons.face,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Visibility(
              visible: userState.role == 3.toString(),
              child: ListTile(
                leading: Icon(
                  Icons.people,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Friends',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return Friends();
                      },
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: userState.foreignUser == 'false' &&
                  (userState.role == 1.toString() ||
                      userState.role == 3.toString()),
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.users,
                  size: 18,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'My Social Posts',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mysocial');
                },
              ),
            ),
            Visibility(
              visible: userState.foreignUser == 'false' &&
                  (userState.role == 2.toString() ||
                      userState.role == 3.toString()),
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.heartbeat,
                  size: 18,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'My Medical Posts',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mymedical');
                },
              ),
            ),
            Visibility(
              visible: userState.foreignUser == 'false' &&
                  userState.role == 1.toString(),
              child: ListTile(
                leading: Icon(
                  Icons.portrait,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'My constituency Posts',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my_constituency_posts');
                },
              ),
            ),
            Visibility(
              visible: userState.foreignUser == 'false' &&
                  userState.role == 2.toString(),
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.heartbeat,
                  size: 18,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'My District Posts',
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my_district_posts');
                },
              ),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.solidNewspaper,
                size: 18,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'My News Feed',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_news_feed');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,color: Theme.of(context).iconTheme.color,),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.signInAlt,
                color: Theme.of(context).iconTheme.color,
                size: 19,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                ),
              ),
              onTap: () {
                logoutApplication();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
