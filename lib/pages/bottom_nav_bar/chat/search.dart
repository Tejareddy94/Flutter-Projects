import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'screens/chat_screen/chat.dart';
import 'services/database.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}
// TODO: Search 
class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      Firestore.instance
          .collection('users')
          .where("firstName", isEqualTo: searchEditingController.text)
          .snapshots()
          .listen((data) {
        setState(() {
          searchResultSnapshot = data;
        });
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                  searchResultSnapshot.documents[index].data["firstName"],
                  "reddy"
                  // searchResultSnapshot.documents[index].data["userEmail"],
                  );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName) {
    List<String> users = ["teja", userName];

    String chatRoomId = getChatRoomId("teja", userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatDetail(
                  chatRoomId: chatRoomId,
                )));
  }

  Widget userTile(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontSize: 16),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              sendMessage(userName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(24)),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF62C0B6)),
                ),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Theme.of(context).textTheme.caption.color,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchEditingController,
                            // style: simpleTextStyle(),
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor),
                            decoration: InputDecoration(
                                hintText: "search username ...",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).backgroundColor,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      const Color(0x36FFFFFF),
                                      const Color(0x0FFFFFFF)
                                    ],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight),
                                borderRadius: BorderRadius.circular(40)),
                            // padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.search,
                              size: 25,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  userList()
                ],
              ),
            ),
    );
  }
}
