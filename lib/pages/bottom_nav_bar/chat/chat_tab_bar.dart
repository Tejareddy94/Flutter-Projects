import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/call_logs.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/chat_rooms.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class ChatTabBar extends StatefulWidget {
  @override
  _ChatTabBarState createState() => _ChatTabBarState();
}

class _ChatTabBarState extends State<ChatTabBar>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);

    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).textTheme.caption.color,
            labelColor: Theme.of(context).textTheme.headline1.color,
            tabs: [
              Tab(
                text: 'Chats',
              ),
              Tab(
                text: 'Call Logs',
              ),
            ],
            controller: _tabController,
            indicatorColor: Theme.of(context).textTheme.headline2.color,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          bottomOpacity: 1,
          title: Text('Chats'),
        ),
        body: TabBarView(
          children: [
            Chatting(),
            CallLogs(),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}
