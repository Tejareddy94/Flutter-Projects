import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/circle_avatar_for_list.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class SearchResult extends StatefulWidget {
  SearchResult({Key key, this.query}) : super(key: key);
  final query;

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final storage = new FlutterSecureStorage();
  var users = [];
  int _currentPage = 1;
  bool _isMore = false;
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  var config;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      this.searchUser(widget.query.toLowerCase(), context,
          currentPage: _currentPage);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      reload();
    }
  }

  reload() async {
    _currentPage = 1;
    users = [];
    var description = widget.query.toLowerCase();
    var currentPage = 1;
    try {
      isLoading = true;
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/user_list/?search=$description&page=$currentPage',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context,
          route: '/friends');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        users = _data["results"];
        if (_data['next'] != null) {
          setState(() {
            _isMore = true;
            _currentPage = 2;
          });
        } else {
          _isMore = false;
        }
        setState(() => isLoading = false);
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'Bearer');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        print("something went wrong");
        return [];
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
    }
     catch (err) {
      print(err);
      return [];
    }
  }

  _getMoreData() {
    if (_isMore) {
      searchUser(widget.query.toLowerCase(), context,
          currentPage: _currentPage);
    }
  }

  searchUser(String description, context, {int currentPage}) async {
    try {
      isLoading = true;
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/user_list/?search=$description&page=$currentPage',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context,
          route: '/friends');
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        users += _data["results"];
        if (_data['next'] != null) {
          setState(() {
            _isMore = true;
            _currentPage++;
          });
        } else {
          _isMore = false;
        }
        setState(() => isLoading = false);
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'Bearer');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        print("something went wrong");
        return [];
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
    }
    catch (err) {
      print(err);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Loading()
          : Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01),
              child: ListView.separated(
                itemCount: users.length + 1,
                controller: _scrollController,
                itemBuilder: (BuildContext ctxt, int index) {
                  if (index == users.length) {
                    if (_isMore == true) {
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                       Theme.of(context).textTheme.headline1.color)
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else if (users.length == 0) {
                    return Container();
                  } else {
                    var user = users[index];
                    return ListTile(
                      leading: CircleAvatarForList(
                        firstName: user["first_name"],
                        lastName: user["last_name"],
                        avatar: user["user_avatar"],
                        dia: 0.12,
                        fontSize: 25.0,
                        parentContext: context,
                      ),
                      title: Text(
                        user["first_name"] + ' ' + user["last_name"],
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: user["constituency_details"] == null ||
                              user["constituency_details"] == ""
                          ? null
                          : Text(
                              user["constituency_details"]["constituency"],
                              style: TextStyle(color: Colors.white70),
                            ),
                      onTap: () {
                        Navigator.pushNamed(context, '/user_profile',
                            arguments: user["id"]);
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
