import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/filter_model.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/chat_tab_bar.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/posts_widget.dart';
import 'package:r2a_mobile/pages/drawer/drawer.dart';
import 'package:r2a_mobile/pages/main_search/app_bar_search.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';
import 'add_posts.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:provider/provider.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({
    Key key,
  }) : super(key: key);
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  bool _isLoading;
  bool _isMore = false;
  int _currentPage = 1;
  final storage = new FlutterSecureStorage();
  ScrollController _scrollController = ScrollController();
  var config; //App config varaible

  List<PostModel> posts = [];
  List _statesList = List();
  List _districtsList = List();
  List _constituencyList = List();
  Filter selectedFilters = Filter();
  UserState userState;

  var state;
  var district;
  var constituency;
  final List<DropdownMenuItem> states = [];
  final List<DropdownMenuItem> districts = [];
  final List<DropdownMenuItem> constituencies = [];
  String filter;
  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      fetchFeeds(currentPage: _currentPage);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  _getMoreData() {
    if (_isMore) {
      fetchFeeds(currentPage: _currentPage);
    }
  }

  void filterNews(String filter) {
    this.filter = filter;
    posts.clear();
    _currentPage = 1;
    fetchFeeds(currentPage: _currentPage);
  }

  Future getStateList() async {
    try {
      final response = await BackendService.get('/auth/states/', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _statesList = _data["data"];
        setState(() {
          _statesList.forEach((state) {
            states.add(DropdownMenuItem(
              child: Text(state['name']),
              value: state['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getDistrictList(int stateId) async {
    try {
      final response =
          await BackendService.get('/auth/districts/$stateId', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _districtsList = _data["data"];
        setState(() {
          _districtsList.forEach((district) {
            districts.add(DropdownMenuItem(
              child: Text(district['name']),
              value: district['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getConstituencyList(int districtId) async {
    try {
      final response = await BackendService.get(
          '/auth/constituencies/$districtId', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _constituencyList = _data["data"];
        setState(() {
          _constituencyList.forEach((constituency) {
            districts.add(DropdownMenuItem(
              child: Text(constituency['name']),
              value: constituency['id'],
            ));
          });
        });
      }
    } catch (e) {
      print(e);
    }
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

  Future fetchFeeds({int currentPage}) async {
    _isLoading = true;
    try {
      var response;
      var bearer = await storage.read(key: 'Bearer');
      if (bearer?.isNotEmpty ?? false) {
        if (currentPage != null && filter != null) {
          response = await BackendService.get(
              '/api/posts/?page=$currentPage&$filter',
              {HttpHeaders.authorizationHeader: "Bearer " + bearer},
              context,
              route: '/newsfeed');
        } else {
          response = await BackendService.get('/api/posts/?page=$currentPage',
              {HttpHeaders.authorizationHeader: "Bearer " + bearer}, context);
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
          setState(() => _isLoading = false);
        } else if (response.statusCode == 401) {
          await storage.deleteAll();
          userState.setUserDetails(
              name: "",
              avatar: "",
              bearer: "",
              phoneNumber: "",
              canCreate: "",
              email: "",
              id: "",
              role: "");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
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
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "${err.message}",
        ),
      );
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    posts = List<PostModel>();
    posts.clear();
    _isMore = false;
    _currentPage = 1;
    fetchFeeds(currentPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);  
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // backgroundColor: Theme.of(context).textTheme.caption.color.withOpacity(0.0),
      // drawer: CustomDrawer(),
      // appBar: AppBar(
      //   leading: Builder(
      //     builder: (BuildContext context) {
      //       return GestureDetector(
      //         onTap: () {
      //           Scaffold.of(context).openDrawer();
      //         },
      //         child: Container(
      //           margin: EdgeInsets.all(10),
      //           child: userState.avatar != null
      //               ? CircleAvatar(
      //                   radius: 30,
      //                   backgroundImage: NetworkImage(userState.avatar),
      //                 )
      //               : CircleAvatar(
      //                   child: Icon(Icons.person),
      //                 ),
      //         ),
      //       );
      //     },
      //   ),
      //   title: Row(
      //     children: [
      //       // Image.asset('assets/images/logomin.png'),
      //       // SizedBox(width: MediaQuery.of(context).size.width*0.02,),
      //       Text('Right To Ask'),
      //     ],
      //   ),
      //   actions: <Widget>[
      //     // IconButton(
      //     //     icon: Icon(
      //     //       Icons.color_lens,
      //     //       color: Theme.of(context).textTheme.caption.color,
      //     //     ),
      //     //     onPressed: () {
      //     //       Provider.of<ThemeModel>(context).toggleTheme();
      //     //     }),
      //     IconButton(
      //         icon: Icon(Icons.search),
      //         onPressed: () {
      //           Provider.of<SearchResultsState>(context).serachResultsClear();
      //           showSearch(context: context, delegate: MainSearch());
      //         }),
      //     IconButton(
      //         icon: Icon(Icons.comment),
      //         onPressed: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (BuildContext context) => ChatTabBar()));
      //         })
      //   ],
      // ),
      body: Column(
        // TODO: remove all the unused functions for filter as it is removed for main news-feed screen
        children: <Widget>[
          _isLoading
              ? Expanded(
                  child: SizedBox(
                    height: 1000,
                    child: RefreshIndicator(
                      onRefresh: refreshList,
                      backgroundColor: Theme.of(context).backgroundColor,
                      color: Theme.of(context).textTheme.headline1.color,
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        controller: _scrollController,
                        itemCount: 2,
                        itemBuilder: (context, int index) {
                          return ShimmeringNewsFeed();
                        },
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    backgroundColor: Theme.of(context).backgroundColor,
                    color: Theme.of(context).textTheme.headline1.color,
                    child: ListView.builder(
                      cacheExtent: 1000,
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      controller: _scrollController,
                      itemCount: posts.length + 1,
                      // itemCount: 1,
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
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .textTheme
                                              .headline1
                                              .color),
                                    ),
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
                )
        ],
      ),
    );
  }
}
