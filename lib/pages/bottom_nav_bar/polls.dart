import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/drawer/drawer.dart';
import 'package:r2a_mobile/pages/main_search/app_bar_search.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class Polls extends StatelessWidget {
  UserState userState;

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    return Scaffold(
      // drawer: CustomDrawer(),
      // appBar: AppBar(
      //   leading: Builder(
      //     builder: (BuildContext context) {
      //       return GestureDetector(
      //         onTap: () {
      //           Scaffold.of(context).openDrawer();
      //         },
      //         child: Container(
      //           margin: EdgeInsets.all(10),
      //           child: userState.avatar != null
      //               ? CircleAvatar(
      //                   radius: 30,
      //                   backgroundImage: NetworkImage(userState.avatar),
      //                 )
      //               : CircleAvatar(
      //                   child: Icon(Icons.person),
      //                 ),
      //         ),
      //       );
      //     },
      //   ),
      //   title: Row(
      //     children: [
      //       Text('Right To Ask'),
      //     ],
      //   ),
      //   actions: <Widget>[
      //     IconButton(
      //         icon: Icon(Icons.search),
      //         onPressed: () {
      //           Provider.of<SearchResultsState>(context).serachResultsClear();
      //           showSearch(context: context, delegate: MainSearch());
      //         }),
      //   ],
      // ),
      body: Container(
        child:
            Center(child: Text("Comming Soon", style: TextStyle(fontSize: 18))),
      ),
    );
  }
}
