import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/shared/chat_timestamp.dart';
import 'package:r2a_mobile/shared/friends_shimmering.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class CallLogs extends StatefulWidget {
  @override
  _CallLogsState createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  ScrollController _scrollController = ScrollController();
  Widget noChats() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: _scrollController,
      itemCount: 1,
      itemBuilder: (context, int index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.12),
              child: FriendsShimmering(),
            ),
            Text(
              'No Chats Found',
              style: TextStyle(color: Colors.white),
            )
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return Firestore.instance
        .collection('callLogs')
        .where("users", arrayContains: userId).limit(30)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    return StreamBuilder<QuerySnapshot>(
      stream: getUserChatRooms(userState.id),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return ListView.builder(
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            controller: _scrollController,
            itemCount: 2,
            cacheExtent: 1000,
            itemBuilder: (context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0),
                    child: FriendsShimmering(),
                  )
                ],
              );
            },
          );
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return ListView.builder(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              controller: _scrollController,
              itemCount: 2,
              itemBuilder: (context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.0),
                      child: FriendsShimmering(),
                    )
                  ],
                );
              },
            );
          default:
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  if (userState.id ==
                      snapshot.data.documents[index].data['caller_id']) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance
                                  .collection("users")
                                  .document(snapshot.data.documents[index]
                                      .data['receiver_id'])
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                switch (userSnapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return FriendsShimmering();
                                    break;
                                  case ConnectionState.none:
                                    return FriendsShimmering();
                                  default:
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                userSnapshot.data['avatarUrl']),
                                      ),
                                      title: Text(
                                        "${userSnapshot.data['firstName']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Icon(
                                            Icons.call_made,
                                            color: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['call_status'] ==
                                                    1
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                          Text(
                                            "${ChatTime.serverTimeFormatter(snapshot.data.documents[index].data['timestamp'].toDate().toString())}",
                                          )
                                        ],
                                      ),
                                    );
                                }
                              }),
                          Divider(
                            height: MediaQuery.of(context).size.height * 0.002,
                            indent: MediaQuery.of(context).size.width * 0.17,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance
                                  .collection("users")
                                  .document(snapshot
                                      .data.documents[index].data['caller_id'])
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                switch (userSnapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return FriendsShimmering();
                                    break;
                                  case ConnectionState.none:
                                    return FriendsShimmering();
                                    break;
                                  default:
                                }
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: CachedNetworkImageProvider(
                                        userSnapshot.data['avatarUrl']),
                                  ),
                                  title: Text(
                                    "${userSnapshot.data['firstName']}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        Icons.call_received,
                                        color: snapshot.data.documents[index]
                                                    .data['call_status'] ==
                                                1
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      Text(
                                        "${ChatTime.serverTimeFormatter(snapshot.data.documents[index].data['timestamp'].toDate().toString())}",
                                      )
                                    ],
                                  ),
                                );
                              }),
                          Divider(
                              height:
                                  MediaQuery.of(context).size.height * 0.002,
                              indent: MediaQuery.of(context).size.width * 0.17),
                        ],
                      ),
                    );
                  }
                });
        }
      },
    );
  }
}
