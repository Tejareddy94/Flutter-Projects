import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/pages/friend/friends_list.dart';
import 'package:r2a_mobile/pages/friend/received_request.dart';
import 'package:r2a_mobile/pages/friend/sent_request.dart';
import 'package:r2a_mobile/pages/search/search.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class Friends extends StatefulWidget {
  Friends({Key key, this.currentIndex}) : super(key: key);
  final currentIndex;
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final storage = new FlutterSecureStorage();
  String avatar;
  int currentIndex = 0;
  UserState userState;
  final List<Widget> _navItems = [
    FriendsList(),
    RequestSentToMe(),
    RequestISent()
  ];

  @override
  void initState() {
    currentIndex = widget.currentIndex != null ? widget.currentIndex : 0;
    super.initState();
  }

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    currentIndex = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.color,
          title: Text('All Friends'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DataSearch(),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          children: _navItems,
          index: currentIndex,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTapped,
          selectedItemColor: Theme.of(context).textSelectionColor,
          unselectedItemColor: Theme.of(context).bottomAppBarColor,
          // fixedColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).appBarTheme.color,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
              ),
              title: Text("Friends"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_downward),
              title: Text("Received Request"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward),
              title: Text("Sent Request"),
            ),
          ],
        ),
      ),
    );
  }
}
