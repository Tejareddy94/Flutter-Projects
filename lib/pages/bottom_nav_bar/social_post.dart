import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/filter_model.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/drawer/drawer.dart';
import 'package:r2a_mobile/pages/main_search/app_bar_search.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';
import 'dart:io';
import 'dart:convert';
import 'post/post_filter.dart';
import 'post/posts_widget.dart';

class SocialPosts extends StatefulWidget {
  const SocialPosts({
    Key key,
  }) : super(key: key);
  @override
  _SocialPostsState createState() => _SocialPostsState();
}

class _SocialPostsState extends State<SocialPosts> {
  bool _isLoading;
  bool _isMore = false;
  int _currentPage = 1;
  ScrollController _scrollController = ScrollController();
  final storage = new FlutterSecureStorage();
  List<PostModel> posts = [];
  var config; //App config varaible
  String filter;
  Filter selectedFilters = Filter();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
    });
    setState(() => _isLoading = true);
    fetchSocial(_currentPage);
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
      fetchSocial(_currentPage);
    }
  }

  Future fetchSocial(int currentPage) async {
    _isLoading = true;
    try {
      var response;
      var bearer = await storage.read(key: 'Bearer');
      if (bearer?.isNotEmpty ?? false) {
        if (currentPage != null && filter != null) {
          response = await BackendService.get(
              '/api/category_posts/1/?page=$currentPage&$filter',
              {HttpHeaders.authorizationHeader: "Bearer " + bearer},
              context);
        } else {
          response = await BackendService.get(
              '/api/category_posts/1/?page=$currentPage',
              {HttpHeaders.authorizationHeader: "Bearer " + bearer},
              context);
        }

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
          if (mounted) setState(() => _isLoading = false);
        } else if (response.statusCode == 401) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        } else {
          setState(() => _isLoading = true);
        }
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
    _isMore = false;
    _currentPage = 1;
    fetchSocial(_currentPage);
  }

  void filterNews(String filter) {
    this.filter = filter;
    posts.clear();
    _currentPage = 1;
    fetchSocial(_currentPage);
  }

  Future deletePost(int id, int index) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.delete('/api/user_post/$id/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, context);
      if (response.statusCode == 200) {
        GlobalSnackBar.show(context, "Post Deleted", Colors.green);
        setState(() {
          posts.removeAt(index);
        });
      } else {
        print("error status code ${response.statusCode}");
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Error Deleting the post",
          ),
        );
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
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "Error Deleting the post",
        ),
      );
    }
  }

  Future singleDeletePost(int id, int index) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.delete('/api/user_post/$id/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, context);
      if (response.statusCode == 200) {
        GlobalSnackBar.show(context, "Post Deleted", Colors.green);
        posts.removeAt(index);
        Navigator.of(context).pop();
      } else {
        print("error status code ${response.statusCode}");
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Error Deleting the post",
          ),
        );
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
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "Error Deleting the post",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    return Scaffold(
     backgroundColor: Theme.of(context).backgroundColor,
    //   drawer: CustomDrawer(),
    //   appBar: AppBar(
    //     leading: Builder(
    //       builder: (BuildContext context) {
    //         return GestureDetector(
    //           onTap: () {
    //             Scaffold.of(context).openDrawer();
    //           },
    //           child: Container(
    //             margin: EdgeInsets.all(10),
    //             child: userState.avatar != null
    //                 ? CircleAvatar(
    //                     radius: 30,
    //                     backgroundImage: NetworkImage(userState.avatar),
    //                   )
    //                 : CircleAvatar(
    //                     child: Icon(Icons.person),
    //                   ),
    //           ),
    //         );
    //       },
    //     ),
    //     title: Text('Right To Ask'),
    //     actions: <Widget>[
    //       IconButton(
    //           icon: Icon(Icons.search),
    //           onPressed: () {
    //             Provider.of<SearchResultsState>(context).serachResultsClear();
    //             showSearch(context: context, delegate: MainSearch());
    //           })
    //     ],
    //   ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 10),
            child: Container(
              height: MediaQuery.of(context).size.width * 0.08,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => FilterNewsFeed(
                            callbackfilter: filterNews,
                            selectedFilter: selectedFilters,
                            refresh: refreshList,
                          )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 5, 0),
                      child: Text(
                        "Filter",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: Theme.of(context).iconTheme.color,
                          size: 25,
                        ),
                        tooltip: 'Filter',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => FilterNewsFeed(
                                    callbackfilter: filterNews,
                                    selectedFilter: selectedFilters,
                                    refresh: refreshList,
                                  )));
                        }),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    backgroundColor: Theme.of(context).backgroundColor,
                    color: Theme.of(context).textTheme.headline1.color,
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemCount: 2,
                      itemBuilder: (context, int index) {
                        return ShimmeringNewsFeed();
                      },
                    ),
                  ),
                )
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    backgroundColor: Theme.of(context).backgroundColor,
                   color: Theme.of(context).textTheme.headline1.color,
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
                                  height:
                                      MediaQuery.of(context).size.height / 5,
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
                                      color:
                                          Theme.of(context).textSelectionColor,
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                          if (_isMore == true) {
                            return Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                )
                              ],
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
                            index: index,
                            deletePost: deletePost,
                            singleDeletepost: singleDeletePost,
                          );
                        }
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
