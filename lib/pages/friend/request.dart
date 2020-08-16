import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/friend/received_request.dart';
import 'package:r2a_mobile/pages/friend/sent_request.dart';

class Request extends StatefulWidget {
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Recieved'),
    Tab(text: 'Sent'),
    // Tab(text: 'Rejected')
  ];

  final List<Widget> _navItems = [RequestSentToMe(), RequestISent()];
  int currentIndex = 0;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          onTap: onTapped,
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Recieved',
            ),
            Tab(
              text: 'Sent',
            ),
            // Tab(text: 'Rejected')
          ],
        ),
        body: IndexedStack(
          children: _navItems,
          index: currentIndex,
        ),
      ),
    );
  }
}
