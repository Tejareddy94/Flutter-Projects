import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/chat_screen/chat.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/shared/friends_shimmering.dart';

class Chatting extends StatefulWidget {
  const Chatting({
    Key key,
  }) : super(key: key);

  @override
  _ChattingState createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  Timer timer;
  Stream chatRooms;
  UserState user;
  var config; //App config varaible
  bool _isLoading;
  ScrollController _scrollController = ScrollController();
  final storage = new FlutterSecureStorage();
  var avatar, userId;
  Future getUserData() async {
    var id = await storage.read(key: 'userId');
    var userAvatar = await storage.read(key: 'avatar');
    if (id != null) {
      if (mounted) {
        setState(() {
          avatar = userAvatar;
          userId = id;
        });
        startTimer();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    Future.delayed(Duration.zero, () {
      getUserData().then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      user = Provider.of<UserState>(context, listen: false);
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    Firestore.instance.collection('users').document("$userId").updateData({
      "status": DateTime.now().toUtc(),
    });
    timer = Timer.periodic(Duration(minutes: 5), (time) {
      Firestore.instance.collection('users').document("$userId").updateData({
        "status": DateTime.now().toUtc(),
      });
    });
  }

  Stream<QuerySnapshot> getUserChatRooms() {
    return Firestore.instance
        .collection('chatRoom')
        .where('users', arrayContains: int.parse(userId))
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUnreadMessages(String id, String userId) {
    return Firestore.instance
        .collection("message")
        .where('groupId', isEqualTo: id)
        .where('receiverId', isEqualTo: userId)
        .where('seen', isEqualTo: false)
        // .getDocuments();
        // .orderBy("timestamp", descending: true)
        .snapshots();
  }

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

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    return
        // userId == null || userId.isEmpty
        // ? Loading()
        // :

        Scaffold(
      body: _isLoading
          ? ListView.builder(
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
            )
          : StreamBuilder<QuerySnapshot>(
              stream: getUserChatRooms(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
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
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.0),
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
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.0),
                              child: FriendsShimmering(),
                            )
                          ],
                        );
                      },
                    );
                  default:
                    return snapshot.data.documents.length < 1
                        ? noChats()
                        : ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (BuildContext context, index) {
                              int oppositeIndex;
                              oppositeIndex = List<int>.from(snapshot
                                              .data.documents[index]['users'])
                                          .indexOf(int.parse(userId)) ==
                                      0
                                  ? 1
                                  : 0;
                              String tenantId = snapshot
                                  .data.documents[index]['users'][oppositeIndex]
                                  .toString();
                              return InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return ChatDetail(
                                      chatRoomId: snapshot
                                          .data.documents[index].documentID,
                                      userId: int.parse(userId),
                                      tenantId: tenantId,
                                    );
                                  }));
                                },
                                child: StreamBuilder<DocumentSnapshot>(
                                    stream: Firestore.instance
                                        .collection("users")
                                        .document(snapshot
                                            .data
                                            .documents[index]['users']
                                                [oppositeIndex]
                                            .toString())
                                        .snapshots(),
                                    builder: (context, userSnapShot) {
                                      switch (userSnapShot.connectionState) {
                                        case ConnectionState.waiting:
                                          // return Text("loading");
                                          return new ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                AlwaysScrollableScrollPhysics(
                                                    parent:
                                                        BouncingScrollPhysics()),
                                            controller: _scrollController,
                                            itemCount: 2,
                                            itemBuilder: (context, int index) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.0),
                                                    child: FriendsShimmering(),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                          break;
                                        default:
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: Container(
                                                    // padding: EdgeInsets.all(10),
                                                    // TODO: implement avatar null
                                                    child: CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              userSnapShot.data
                                                                      .data[
                                                                  'avatarUrl']),
                                                    ),
                                                  ),
                                                  title: Text(
                                                      "${userSnapShot.data.data['firstName']}"),
                                                  subtitle: snapshot.data
                                                                  .documents[index]
                                                              ['type'] ==
                                                          0
                                                      ? Text(
                                                          "${snapshot.data.documents[index]['last_message']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )
                                                      : snapshot.data.documents[index]
                                                                  ['type'] ==
                                                              1
                                                          ? Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.image,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption
                                                                      .color,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.01,
                                                                ),
                                                                Text("Image"),
                                                              ],
                                                            )
                                                          : snapshot.data.documents[index]
                                                                      ['type'] ==
                                                                  2
                                                              ? Row(
                                                                  children: [
                                                                    FaIcon(
                                                                      FontAwesomeIcons
                                                                          .video,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .caption
                                                                          .color,
                                                                      size: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.04,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.01,
                                                                    ),
                                                                    Text(
                                                                        "Video"),
                                                                  ],
                                                                )
                                                              : snapshot.data.documents[index]['type'] == 3
                                                                  ? Row(
                                                                      children: [
                                                                        FaIcon(
                                                                          FontAwesomeIcons
                                                                              .headphones,
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .caption
                                                                              .color,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        Text(
                                                                            "Audio"),
                                                                      ],
                                                                    )
                                                                  : Text("other"),
                                                  trailing: StreamBuilder<
                                                          QuerySnapshot>(
                                                      stream: getUnreadMessages(
                                                          snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID,
                                                          user.id),
                                                      builder: (context,
                                                          countSnapshot) {
                                                        switch (countSnapshot
                                                            .connectionState) {
                                                          case ConnectionState
                                                              .none:
                                                            return Text("");
                                                          case ConnectionState
                                                              .waiting:
                                                            return Text("");
                                                            break;
                                                          default:
                                                            return  countSnapshot.data.documents.length<=0 ? SizedBox.shrink() : Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(MediaQuery.of(context).size.width*0.013),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                color:
                                                                    Colors.red,
                                                                // borderRadius:
                                                                //     BorderRadius
                                                                //         .circular(
                                                                //             30),
                                                              ),
                                                              constraints:
                                                                  BoxConstraints(
                                                                minWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.02,
                                                                minHeight: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              child: Text(
                                                                  "${countSnapshot.data.documents.length}"),
                                                            );
                                                        }
                                                      }),
                                                ),
                                                Divider(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.002,
                                                    indent:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.17),
                                              ],
                                            ),
                                          );
                                      }
                                    }),
                              );
                              // return Text("${snapshot.data.documents[index]['chatroomname']}");
                            },
                          );
                }
              },
            ),
    );
  }
}
