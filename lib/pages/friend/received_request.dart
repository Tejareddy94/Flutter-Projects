import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/friends_model.dart';
import 'package:r2a_mobile/pages/friend/friend_request_model.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/circle_avatar_for_list.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/friends_shimmering.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class RequestSentToMe extends StatefulWidget {
  @override
  _RequestSentToMeState createState() => _RequestSentToMeState();
}

class _RequestSentToMeState extends State<RequestSentToMe> {
  final storage = new FlutterSecureStorage();
  var users = [];
  var isLoading = true;
  int _currentPage = 1;
  bool _isMore = false;
  ScrollController _scrollController = ScrollController();
  List<FriendRequestModel> receivedfriendRequests = [];
  ReceivedFriendRequestState receivedFriendRequestState;
  FriendsListState friendsListState;

  @override
  void initState() {
    this.getFriendRequestList(currentPage: _currentPage);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    super.initState();
  }

  _getMoreData() {
    if (_isMore) {
      getFriendRequestList(currentPage: _currentPage);
    }
  }

  getFriendRequestList({int currentPage, bool isPull}) {
    Future.delayed(Duration.zero, () async {
      var bearer = await storage.read(key: 'Bearer');
      try {
        final response = await BackendService.get(
            '/api/friends/requests_list/?page=$currentPage',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context,
            route: '/friends');

        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          for (var friendRequest in _data['results']) {
            FriendRequestModel friendRequestModel =
                FriendRequestModel.fromJson(friendRequest);
            receivedfriendRequests.add(friendRequestModel);
          }
          receivedFriendRequestState
              .setReceivedRequests(receivedfriendRequests);
          if (isPull == true) {
            users = _data["results"];
          } else {
            users += _data["results"];
          }
          if (_data['next'] != null) {
            setState(() {
              _isMore = true;
              _currentPage++;
            });
          } else {
            _isMore = false;
          }
          setState(() {
            isLoading = false;
          });
        } else if (response.statusCode == 401) {
          await storage.deleteAll();
          UserState userState = Provider.of<UserState>(context, listen: true);
          userState.setUserDetails(
              name: "",
              email: "",
              bearer: "",
              canCreate: "",
              phoneNumber: "",
              role: "",
              avatar: "");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        } else {
          print('Something went wrong!');
          setState(() => isLoading = false);
          refreshList();
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
    });
  }

  rejectRequest(context, reqId, friendRequestIndex) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.delete(
          '/api/friends/delete_request/$reqId/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context,
          route: '/friends');
      if (response.statusCode == 200) {
        GlobalSnackBar.show(context, "Friend Request Canceled", Colors.red);
        setState(() {
          receivedfriendRequests.removeAt(friendRequestIndex);
        });
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'Bearer');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        print('Something went wrong!');
        this.setState(() {
          users = [];
        });
        refreshList();
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

  acceptRequest(context, reqId, friendRequestIndex) async {
    var bearer = await storage.read(key: 'Bearer');
    var header = {HttpHeaders.authorizationHeader: "Bearer " + bearer};
    BackendService.get(
            '/api/friends/accept_request/' + reqId.toString(), header, context,
            route: '/friends')
        .then(
      (response) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          GlobalSnackBar.show(context, "Friend Request Accepted", Colors.green);
          setState(() {
            receivedfriendRequests.removeAt(friendRequestIndex);
          });

          FriendsModel friendModel = FriendsModel.fromJson(data["data"]);
          final friendsList = friendsListState.getFriendList();
          friendsList.add(friendModel);
          friendsListState.setFriendList(friendsList);
        } else {
          print('Something went wrong!');
          this.setState(() {
            users = [];
          });
          refreshList();
        }
      },
    );
  }

  Future<Null> refreshList() async {
    users = [];
    _isMore = false;
    _currentPage = 1;
    getFriendRequestList(currentPage: _currentPage, isPull: true);
  }

  @override
  Widget build(BuildContext context) {
    receivedFriendRequestState =
        Provider.of<ReceivedFriendRequestState>(context, listen: true);
    friendsListState = Provider.of<FriendsListState>(context, listen: true);
    return isLoading == true
        ? Column(
            children: <Widget>[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, int index) {
                  return FriendsShimmering();
                },
              ),
            ],
          )
        : receivedfriendRequests.length == 0
            ? RefreshIndicator(
                onRefresh: refreshList,
                backgroundColor: Theme.of(context).backgroundColor,
                color: Theme.of(context).primaryColor,
                notificationPredicate: defaultScrollNotificationPredicate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.12),
                      child: FriendsShimmering(),
                    ),
                    Text(
                      'No Pending Friend Requests',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: refreshList,
                backgroundColor: Theme.of(context).backgroundColor,
                color: Theme.of(context).primaryColor,
                notificationPredicate: defaultScrollNotificationPredicate,
                child: Container(
                  child: ListView.separated(
                    itemCount: receivedfriendRequests.length + 1,
                    controller: _scrollController,
                    itemBuilder: (BuildContext ctxt, int index) {
                      if (index == receivedfriendRequests.length) {
                        if (_isMore == true) {
                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      } else if (receivedfriendRequests.length == 0) {
                        return Container();
                      } else {
                        final user = receivedfriendRequests[index].fromUser;
                        return ListTile(
                          leading: CircleAvatarForList(
                            firstName: user.first_name,
                            lastName: user.last_name,
                            avatar: user.profile.avatar,
                            dia: 0.12,
                            fontSize: 25.0,
                            parentContext: context,
                          ),
                          title: Text(
                            user.first_name + " " + user.last_name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18.0),
                          ),
                          subtitle: user.constituencyDetails == null
                              ? null
                              : Text(
                                  user.constituencyDetails.constituency,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Color(0xFFbabbbf)),
                                ),
                          onTap: () {
                            Navigator.pushNamed(context, '/user_profile',
                                arguments: user.id);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  acceptRequest(context,
                                      receivedfriendRequests[index].id, index);
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).backgroundColor,
                                  child: Icon(
                                    Icons.done,
                                    color: Color(0xFF47a97c),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.04,
                              ),
                              InkWell(
                                onTap: () {
                                  rejectRequest(context,
                                      receivedfriendRequests[index].id, index);
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).backgroundColor,
                                  child: Icon(
                                    Icons.clear,
                                    color: Color(0xFFe14a48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                          height: MediaQuery.of(context).size.height * 0.002,
                          indent: MediaQuery.of(context).size.width * 0.17);
                    },
                  ),
                ),
              );
  }
}
