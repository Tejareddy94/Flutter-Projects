import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/posts_widget.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'dart:io';
import 'dart:convert';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class MySocialPost extends StatefulWidget {
  @override
  _MySocialPostState createState() => _MySocialPostState();
}

class _MySocialPostState extends State<MySocialPost> {
  bool _isLoading;
  bool _isMore = false;
  int _currentPage = 1;
  ScrollController _scrollController = ScrollController();
  final storage = new FlutterSecureStorage();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PostModel> posts = [];
  var config; //App config varaible
  var bearer;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
    });
    setState(() => _isLoading = true);
    fetchPlotical(_currentPage);
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
      fetchPlotical(_currentPage);
    }
  }

  Future deletePost(int id, int index) async {
    try {
      final response = await BackendService.delete('/api/user_post/$id/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, context);
      if (response.statusCode == 200) {
        customRoundedSnackBar(
            message: "Post Deleted",
            sacffoldState: scaffoldKey.currentState,
            color: Colors.green);
        setState(() {
          posts.removeAt(index);
        });
      } else {
        print("error status code ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchPlotical(int currentPage) async {
    _isLoading = true;
    try {
      bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/user_category_posts/1/?page=$currentPage',
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      } else {
        setState(() => _isLoading = true);
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
    await Future.delayed(Duration(seconds: 2));
    posts = List<PostModel>();
    posts.clear();
    _isMore = false;
    _currentPage = 1;
    fetchPlotical(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("My Social"),
        ),
        body: _isLoading
            ? Column(
                children: <Widget>[
                  ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    primary: false,
                    shrinkWrap: true,
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
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  controller: _scrollController,
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
                                      MediaQuery.of(context).size.width * 0.1),
                              child: Text(
                                "Once you add a new post you will see it listed here",
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
                    } else if (posts.length == 0) {
                      return Container(
                        child: Center(
                          child: Text("No Data"),
                        ),
                      );
                    } else {
                      return PostsWidget(
                          post: posts[index],
                          deletePost: deletePost,
                          index: index);
                    }
                  },
                ),
              ),
      ),
    );
  }
}
