import 'dart:convert';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/posts_widget.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class UserNewsFeed extends StatefulWidget {
  UserNewsFeed({Key key, this.userId}) : super(key: key);
  final userId;

  @override
  _UserNewsFeedState createState() => _UserNewsFeedState();
}

class _UserNewsFeedState extends State<UserNewsFeed> {
  bool _isLoading;
  bool _isMore = false;
  int _currentPage = 1;
  final storage = new FlutterSecureStorage();
  ScrollController _scrollController = ScrollController();
  var config; //App config varaible
  var avatar, profileName, email;

  // List posts = [];
  List<PostModel> posts = [];

  @override
  void initState() {
    setState(() => _isLoading = true);
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      fetchFeeds(_currentPage);
    });
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
      fetchFeeds(_currentPage);
    }
  }

  Future fetchFeeds(currentPage) async {
    _isLoading = true;
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/user_recent_posts/${widget.userId}?page=$currentPage',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        for (var post in _data['results']) {
          PostModel postModel = PostModel.fromJson(post);
          posts.add(postModel);
        }
        if (_data['next'] != null) {
          setState(() {
            _isMore = true;
            _currentPage++;
          });
        } else {
          _isMore = false;
        }
        setState(() => _isLoading = false);
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'Bearer');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        setState(() => _isLoading = false);
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

  Future<Null> refreshList() async {
    posts = [];
    _isMore = false;
    _currentPage = 1;
    fetchFeeds(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Posts'),
      ),
      body: _isLoading
          ? Column(
              children: <Widget>[
                ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  primary: false,
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: 2,
                  itemBuilder: (context, int index) {
                    return ShimmeringNewsFeed();
                  },
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: refreshList,
              backgroundColor: Theme.of(context).backgroundColor,
              color: Theme.of(context).primaryColor,
              notificationPredicate: defaultScrollNotificationPredicate,
              child: Container(
                child: ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    controller: _scrollController,
                    // itemExtent: 100,
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        if (posts.length == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 5,
                              ),
                              EmptyDataWidget(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1),
                                child: Text(
                                  "Currently There are no Posts Available",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          );
                        }
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
                      } else {
                        return PostsWidget(post: posts[index]);
                      }
                    }),
              ),
            ),
    );
  }
}
