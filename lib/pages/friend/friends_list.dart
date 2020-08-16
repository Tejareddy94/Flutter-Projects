import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/friends_model.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/circle_avatar_for_list.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/friends_shimmering.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final storage = new FlutterSecureStorage();
  var users = [];
  var isLoading = true;
  int _currentPage = 1;
  bool _isMore = false;
  ScrollController _scrollController = ScrollController();
  List<FriendsModel> friends = [];
  FriendsListState friendsListState;

  @override
  void initState() {
    this.getFriendList(currentPage: _currentPage);
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
      getFriendList(currentPage: _currentPage);
    }
  }

  getFriendList({int currentPage, bool isPull}) {
    Future.delayed(Duration.zero, () async {
      isLoading = true;
      try {
        var bearer = await storage.read(key: 'Bearer');
        final response = await BackendService.get(
            '/api/friends/list/?page=$currentPage',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context,
            route: '/friends');
        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          if (isPull == true) {
            users = _data["results"];
          } else {
            users += _data["results"];
          }
          for (var post in _data['results']) {
            FriendsModel friendModel = FriendsModel.fromJson(post);
            friends.add(friendModel);
          }
          friendsListState.setFriendList(friends);
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

  Future<Null> refreshList() async {
    users = [];
    friends = List<FriendsModel>();
    _isMore = false;
    _currentPage = 1;
    getFriendList(currentPage: _currentPage, isPull: true);
  }

  @override
  Widget build(BuildContext context) {
    friendsListState = Provider.of<FriendsListState>(context, listen: true);
    return isLoading == true
        ? Column(
            children: <Widget>[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, int index) {
                  return FriendsShimmering();
                },
              ),
            ],
          )
        : friends.length == 0
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
                      'No Friends',
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
                    itemCount: friends.length + 1,
                    controller: _scrollController,
                    itemBuilder: (BuildContext ctxt, int index) {
                      if (index == friends.length) {
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
                      } else if (friends.length == 0) {
                        return Container();
                      } else {
                        return ListTile(
                          leading: CircleAvatarForList(
                            firstName: friends[index].first_name,
                            lastName: friends[index].last_name,
                            avatar: friends[index].user_avatar,
                            dia: 0.12,
                            fontSize: 25.0,
                            parentContext: context,
                          ),
                          title: Text(
                            friends[index].first_name +
                                " " +
                                friends[index].last_name,
                            style: TextStyle(fontSize: 18.0),
                          ),
                          subtitle: friends[index].constituency_details == null
                              ? null
                              : Text(
                                  friends[index]
                                      .constituency_details
                                      .constituency,
                                  style: TextStyle(color: Color(0xFFbabbbf)),
                                ),
                          onTap: () {
                            Navigator.pushNamed(context, '/user_profile',
                                arguments: friends[index].id);
                          },
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
