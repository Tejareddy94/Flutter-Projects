import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/friends_model.dart';
import 'package:r2a_mobile/pages/friend/friend_request_model.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key key, this.userId}) : super(key: key);
  final userId;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool isLoading = true;
  final storage = new FlutterSecureStorage();
  var userDetails = {};
  final sex = ["", "Male", "Female", "Private"];
  final role = [
    "",
    "Political Representative",
    "Medical Representative",
    "User"
  ];
  SentFriendRequestState sentFriendRequestState;
  FriendsListState friendsListState;
  ReceivedFriendRequestState receivedFriendRequestState;

  @override
  void initState() {
    this.getUserDetails();
    super.initState();
  }

  getUserDetails() {
    Future.delayed(Duration.zero, () async {
      var bearer = await storage.read(key: 'Bearer');
      var header = {HttpHeaders.authorizationHeader: "Bearer " + bearer};
      BackendService.get(
              '/api/user/' + widget.userId.toString(), header, context)
          .then(
        (response) {
          final data = jsonDecode(response.body);

          if (response.statusCode == 200) {
            setState(() {
              userDetails = data["data"];
              isLoading = false;
            });
          } else {
            print('Something went wrong!');
          }
        },
      );
    });
  }

  unfriendUser(context) async {
    var bearer = await storage.read(key: 'Bearer');
    try {
      var data = {"recipient_id": widget.userId};
      final response = await BackendService.post('/api/friends/unfriend/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, data, context);
      if (response.statusCode == 200) {
        final friendsList = friendsListState.getFriendList();
        if (friendsListState.getFriendList().length > 0) {
          for (var i = 0; i < friendsList.length; i++) {
            if (friendsList[i].id == widget.userId) {
              friendsList.removeAt(i);
            }
          }
          this.getUserDetails();
        }
      } else {
        print("error status code ${response.statusCode}");
        getUserDetails();
      }
    } on SocketException catch (e) {
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "${e.message}",
        ),
      );
    } on SessionTimeOutException catch (e) {
      showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
                message: "${e.message}",
              ));
    } catch (e) {
      print(e);
    }
  }

  sendFriendRequest(context) async {
    var bearer = await storage.read(key: 'Bearer');
    try {
      var data = {
        "recipient_id": widget.userId,
        "message": "accept my request",
      };
      final response = await BackendService.post('/api/friends/create/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, data, context);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        FriendRequestModel friendRequestModel =
            FriendRequestModel.fromJson(data["data"]);
        final sentFriendRequests = sentFriendRequestState.getSentRequests();
        sentFriendRequests.add(friendRequestModel);
        getUserDetails();
      } else {
        print("error status code ${response.statusCode}");
        getUserDetails();
      }
    } on SocketException catch (e) {
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "${e.message}",
        ),
      );
    } on SessionTimeOutException catch (e) {
      showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
                message: "${e.message}",
              ));
    } catch (e) {
      print(e);
    }
  }

  rejectRequest(context, reqId) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.delete(
          '/api/friends/delete_request/$reqId/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context,
          route: '/friends');
      if (response.statusCode == 200) {
        if (userDetails["request_sent"]["can_create"] == false &&
            userDetails["request_sent"]["sent_by"] == "other") {
          final receivedFriendRequest =
              receivedFriendRequestState.getReceivedRequests();
          if (receivedFriendRequest.length > 0) {
            for (var i = 0; i < receivedFriendRequest.length; i++) {
              if (receivedFriendRequest[i].id == reqId) {
                receivedFriendRequest.removeAt(i);
              }
            }
            this.getUserDetails();
          }
        } else {
          final sentFriendRequests = sentFriendRequestState.getSentRequests();
          if (sentFriendRequests.length > 0) {
            for (var i = 0; i < sentFriendRequests.length; i++) {
              if (sentFriendRequests[i].id == reqId) {
                sentFriendRequests.removeAt(i);
              }
            }
            this.getUserDetails();
          }
        }
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'Bearer');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        print("error status code ${response.statusCode}");
        getUserDetails();
      }
    } on SocketException catch (e) {
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "${e.message}",
        ),
      );
    } on SessionTimeOutException catch (e) {
      showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
                message: "${e.message}",
              ));
    } catch (err) {
      print(err);
    }
  }

  acceptRequest(context, reqId) async {
    var bearer = await storage.read(key: 'Bearer');
    var header = {HttpHeaders.authorizationHeader: "Bearer " + bearer};
    BackendService.get(
            '/api/friends/accept_request/' + reqId.toString(), header, context,
            route: '/friends')
        .then(
      (response) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final receivedFriendRequest =
              receivedFriendRequestState.getReceivedRequests();
          if (receivedFriendRequestState.getReceivedRequests().length > 0) {
            for (var i = 0; i < receivedFriendRequest.length; i++) {
              if (receivedFriendRequest[i].id == reqId) {
                receivedFriendRequest.removeAt(i);
              }
            }
          }

          FriendsModel friendModel = FriendsModel.fromJson(data["data"]);
          final friendsList = friendsListState.getFriendList();
          friendsList.add(friendModel);
          this.getUserDetails();
        } else {
          print('Something went wrong!');
          getUserDetails();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final user = Provider.of<UserState>(context);
    sentFriendRequestState =
        Provider.of<SentFriendRequestState>(context, listen: true);
    friendsListState = Provider.of<FriendsListState>(context, listen: true);
    receivedFriendRequestState =
        Provider.of<ReceivedFriendRequestState>(context, listen: true);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.9),
      body: isLoading
          ? Loading()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  stretch: true,

                  // backgroundColor: Color(0xFF303136),
                  expandedHeight: height * 0.3,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    stretchModes: [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                      // StretchMode.blurBackground
                    ],
                    title: Text(
                      userDetails["admin"] == true ||
                              userDetails["anonymous"] == true &&
                                  userDetails["are_friends"] == false
                          ? '${userDetails["first_name"]} ${userDetails["last_name"]}'
                          : '${userDetails["first_name"]} ${userDetails["last_name"]}',
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    background: Image.network(
                      userDetails["user_avatar"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      userDetails["admin"] == true ||
                              userDetails["role"] == 2 ||
                              userDetails["role"] == 1 ||
                              user.role == "1" ||
                              user.role == "2"
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(
                                  left: width * 0.05,
                                  right: width * 0.05,
                                  top: height * 0.04),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  // userDetails["are_friends"] == true
                                  //     ? FlatButton(
                                  //         color: Theme.of(context).buttonColor,
                                  //         textColor: Colors.black87,
                                  //         disabledColor: Colors.grey,
                                  //         disabledTextColor: Colors.black,
                                  //         padding: EdgeInsets.all(8.0),
                                  //         splashColor: Colors.blueAccent,
                                  //         onPressed: () {
                                  //           // message;
                                  //         },
                                  //         child: Container(
                                  //           width: width * 0.35,
                                  //           child: Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.center,
                                  //             children: <Widget>[
                                  //               Icon(
                                  //                 Icons.message,
                                  //                 size: 20.0,
                                  //               ),
                                  //               Text(
                                  //                 "  Message",
                                  //                 style:
                                  //                     TextStyle(fontSize: 13.0),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  userDetails["are_friends"] == true
                                      ? Container()
                                      : userDetails["request_sent"]
                                                      ["can_create"] ==
                                                  false &&
                                              userDetails["request_sent"]
                                                      ["sent_by"] ==
                                                  "other"
                                          ? FlatButton(
                                              color:
                                                  Theme.of(context).buttonColor,
                                              textColor: Colors.black87,
                                              disabledColor: Color(0xFF4f535c),
                                              disabledTextColor: Colors.white70,
                                              padding: EdgeInsets.all(8.0),
                                              splashColor: Colors.blueAccent,
                                              onPressed: () {
                                                acceptRequest(
                                                    context,
                                                    userDetails["request_sent"]
                                                        ["request_id"]);
                                              },
                                              child: Container(
                                                width: width * 0.35,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "Confirm Request",
                                                      style: TextStyle(
                                                          fontSize: 13.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                  userDetails["are_friends"] == true
                                      ? FlatButton(
                                          color: Color(0xFF4f535c),
                                          textColor:
                                              Theme.of(context).backgroundColor,
                                          disabledColor: Colors.grey,
                                          disabledTextColor: Colors.black,
                                          padding: EdgeInsets.all(8.0),
                                          splashColor: Theme.of(context)
                                              .backgroundColor
                                              .withOpacity(0.5),
                                          onPressed: () {
                                            // Unfriend
                                            this.unfriendUser(context);
                                          },
                                          child: Container(
                                            width: width * 0.35,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                // Icon(
                                                //   Icons.remove_circle_outline,
                                                //   size: 20.0,
                                                // ),
                                                Text(
                                                  "Unfriend",
                                                  style:
                                                      TextStyle(fontSize: 13.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : userDetails["request_sent"]
                                                  ["can_create"] ==
                                              false
                                          ? FlatButton(
                                              color: Colors.white54,
                                              textColor: Colors.black87,
                                              disabledColor: Color(0xFF4f535c),
                                              disabledTextColor: Colors.white70,
                                              padding: EdgeInsets.all(8.0),
                                              splashColor: Colors.blueAccent,
                                              onPressed: () {
                                                rejectRequest(
                                                    context,
                                                    userDetails["request_sent"]
                                                        ["request_id"]);
                                              },
                                              child: Container(
                                                width: width * 0.35,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "Cancel Request",
                                                      style: TextStyle(
                                                          fontSize: 13.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : FlatButton(
                                              color:
                                                  Theme.of(context).buttonColor,
                                              textColor: Theme.of(context)
                                                  .backgroundColor,
                                              disabledColor: Colors.grey,
                                              disabledTextColor: Colors.black,
                                              padding: EdgeInsets.all(8.0),
                                              splashColor: Theme.of(context)
                                                  .buttonColor
                                                  .withOpacity(0.5),
                                              onPressed: () {
                                                // Add Friend
                                                this.sendFriendRequest(context);
                                              },
                                              child: Container(
                                                width: width * 0.35,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.person_add,
                                                      size: 20.0,
                                                    ),
                                                    Text(
                                                      "  Add Friend",
                                                      style: TextStyle(
                                                          fontSize: 13.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                ],
                              ),
                            ),
                      userDetails["role"] == 2 || userDetails["role"] == 1
                          ? Container(
                              child: Card(
                                color: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    right: width * 0.05,
                                    top: height * 0.040),
                                elevation: 2,
                                child: ClipPath(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.person,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'Role',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            role[userDetails["role"]],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      userDetails["admin"] == true ||
                              userDetails["anonymous"] == true &&
                                  userDetails["are_friends"] == false ||
                              userDetails["role"] == 2 ||
                              userDetails["role"] == 1
                          ? Container()
                          : Container(
                              child: Card(
                                color: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    right: width * 0.05,
                                    top: height * 0.040),
                                elevation: 2,
                                child: ClipPath(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.phone,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'Phone',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            userDetails["phone_number"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .body1
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                        Divider(
                                          indent: width * 0.17,
                                          endIndent: width * 0.08,
                                        ),
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.email,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'Email',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            userDetails["email"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      userDetails["admin"] == true ||
                              userDetails["anonymous"] == true &&
                                  userDetails["are_friends"] == false ||
                              userDetails["role"] == 2 ||
                              userDetails["role"] == 1
                          ? Container()
                          : Container(
                              child: Card(
                                color: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    right: width * 0.05,
                                    top: height * 0.04),
                                elevation: 2,
                                child: ClipPath(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.person_outline,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'Gender',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            sex[userDetails["profile"]["sex"]],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                        Divider(
                                          indent: width * 0.17,
                                          endIndent: width * 0.08,
                                        ),
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.date_range,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'Date Of Birth',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            userDetails["profile"]["dob"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      userDetails["admin"] == true ||
                              userDetails["constituency_details"] == null
                          ? Container()
                          : Container(
                              child: Card(
                                color: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    right: width * 0.05,
                                    top: height * 0.04),
                                elevation: 2,
                                child: ClipPath(
                                  child: Container(
                                    // height: 300,
                                    // decoration: BoxDecoration(
                                    //   border: Border(
                                    //     right: BorderSide(
                                    //         color: Color(0xFF7289D9),
                                    //         width: width * 0.01),
                                    //   ),
                                    // ),
                                    child: Column(
                                      children: <Widget>[
                                        userDetails["role"] == 2
                                            ? Container()
                                            : ListTile(
                                                dense: true,
                                                leading: Container(
                                                  padding: EdgeInsets.only(
                                                      top: height * 0.01),
                                                  child: Icon(
                                                    Icons.my_location,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                                title: Text(
                                                  'Constituency',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .color,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  userDetails[
                                                          "constituency_details"]
                                                      ["constituency"],
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .color,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ),
                                        userDetails["role"] == 2
                                            ? Container()
                                            : Divider(
                                                indent: width * 0.17,
                                                endIndent: width * 0.08,
                                              ),
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.place,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'District',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            userDetails["constituency_details"]
                                                ["district"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                        Divider(
                                          indent: width * 0.17,
                                          endIndent: width * 0.08,
                                        ),
                                        ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Icon(
                                              Icons.place,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                          title: Text(
                                            'State',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                            ),
                                          ),
                                          subtitle: Text(
                                            userDetails["constituency_details"]
                                                ["state"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Container(
                        child: Card(
                          color: Theme.of(context).backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: width * 0.05,
                              vertical: height * 0.04),
                          elevation: 2,
                          child: ClipPath(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    dense: true,
                                    leading: Container(
                                      padding:
                                          EdgeInsets.only(top: height * 0.01),
                                      child: Icon(
                                        Icons.filter_none,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                        size: 20.0,
                                      ),
                                    ),
                                    title: Text(
                                      'Recent Posts',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .color,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/user_news_feed',
                                          arguments: widget.userId);
                                    },
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
