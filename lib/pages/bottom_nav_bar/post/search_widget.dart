import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'dart:convert';
import 'dart:io';
import 'package:r2a_mobile/shared_state/user.dart';
import 'search_post_widget.dart';

class SearchWidget extends StatefulWidget {
  final String query;

  const SearchWidget({Key key, this.query}) : super(key: key);
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final storage = new FlutterSecureStorage();
  List<PostModel> posts = [];
  UserState userState;
  SearchResultsState post;
  bool _isLoading;
  bool _isMore = false;
  int _currentPage = 1;
  ScrollController _scrollController = ScrollController();
  var config; //App config varaible
  @override
  void initState() {
    setState(() => _isLoading = true);
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
      fetchFeeds();
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
      fetchFeeds();
    }
  }

  Future fetchFeeds() async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/posts/?search=${widget.query}&page=$_currentPage',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        for (var post in _data['results']) {
          PostModel postModel = PostModel.fromJson(post);
          posts.add(postModel);
        }
        post.searchResults(posts);
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
      }
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
    fetchFeeds();
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    post = Provider.of<SearchResultsState>(context, listen: true);

    return Column(
      children: <Widget>[
        _isLoading
            ? Expanded(
                child: SizedBox(
                  height: 1000,
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    backgroundColor: Theme.of(context).backgroundColor,
                    color: Theme.of(context).primaryColor,
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
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1),
                                child: Text(
                                  "Currently There Are No Posts Matching Your Query",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              EmptyDataWidget(),
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
                        return SearchPost(
                          post: posts[index],
                          index: index,
                        );
                      }
                    },
                  ),
                ),
              )
      ],
    );
  }
}
