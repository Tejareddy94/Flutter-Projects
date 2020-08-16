import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/comment_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/date_time_format.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';
import 'package:r2a_mobile/utils/emoji_decode.dart';
import 'package:r2a_mobile/service/backend_service.dart';

class PostComments extends StatefulWidget {
  final PostModel post;
  const PostComments({Key key, this.post}) : super(key: key);
  @override
  _PostCommentsState createState() => _PostCommentsState();
}

enum CommentsOptions { edit, delete }

class _PostCommentsState extends State<PostComments> {
  TextEditingController textEditingController;
  bool isWiritng = false;
  bool _isLoading;
  int _currentPage = 1;
  bool _isMore = false;
  bool _editCommet = false;
  int commentId;
  int commentIndex;
  final storage = new FlutterSecureStorage();
  List<Comments> comments = [];
  ScrollController _scrollController = ScrollController();
  String comment;
  var bearer;
  var config; //App config varaible
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchComments(_currentPage);
      this.config = AppConfig.of(context);
    });
    textEditingController = TextEditingController();
    setState(() => _isLoading = true);
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
    textEditingController?.dispose();
    super.dispose();
  }

  _refresh() {
    comments = [];
    _isMore = false;
    _currentPage = 1;
    fetchComments(_currentPage);
  }

  _getMoreData() {
    if (_isMore) {
      fetchComments(_currentPage);
    }
  }

  Future deleteComment(int id, int index) async {
    try {
      final response = await BackendService.delete(
          '/api/comment_update_delete/$id/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        setState(() {
          widget.post.commentsCount--;
          comments.removeAt(index);
        });
      } else {
        print("error status code ${response.statusCode}");
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

  Future createComment(int postId, String message) async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => textEditingController.clear()); //clear the text in comment box
    Comments tempComment = Comments(
        postId, "Posting...", true, message, DateTime.now().toString(), 1, 1);
    setState(() => comments.insert(0, tempComment));
    try {
      var data = {"message": message};
      final response = await BackendService.post('/api/create_comment/$postId/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, data, context);
      if (response.statusCode == 200) {
        widget.post.commentsCount++;
        _refresh();
      } else {
        print("error status code ${response.statusCode}");
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

  Future updateComment(String message) async {
    _editCommet = false;
    FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => textEditingController.clear()); //clear the text in comment box
    var data = {"message": comment};
    try {
      final response = await BackendService.put(
          '/api/comment_update_delete/$commentId/',
          {
            HttpHeaders.authorizationHeader: "Bearer " + bearer,
            "Content-type": "application/json"
          },
          data,
          context);
      if (response.statusCode == 200) {
        _refresh();
        setState(() {
          // comments.insert(0, );
        });
      } else {
        print("error status code ${response.statusCode}");
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

  Future fetchComments(int currentPage) async {
    _isLoading = true;
    try {
      bearer = await storage.read(key: 'Bearer');
      //  final response =
      // await http.get(config.baseUrl +'/api/post_comments/${widget.post.id}/?page=$currentPage', headers:  {HttpHeaders.authorizationHeader: "Bearer " + bearer},);
      final response = await BackendService.get(
          '/api/post_comments/${widget.post.id}/?page=$currentPage',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        widget.post.commentsCount = _data['count'];
        for (var post in _data['results']) {
          Comments commentsModel = Comments.fromJson(post);
          comments.add(commentsModel);
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
    comments = List<Comments>();
    _isMore = false;
    _currentPage = 1;
    fetchComments(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);

    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text("Comments"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              _isLoading
                  ? Expanded(
                      child: Center(
                          child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    )))
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: comments.isEmpty
                            ? Center(
                                child: Text(
                                  "No comments to Display",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : commentList(),
                      ),
                    ),
              commentSendTextField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget commentList() {
    return RefreshIndicator(
      onRefresh: refreshList,
      backgroundColor: Theme.of(context).backgroundColor,
      color: Theme.of(context).primaryColor,
      notificationPredicate: defaultScrollNotificationPredicate,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        controller: _scrollController,
        itemCount: comments.length + 1,
        itemBuilder: (context, index) {
          if (index == comments.length) {
            if (_isMore == true) {
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          } else if (comments.length == 0) {
            return Container();
          } else {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor,
              ),
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                title: Row(
                  children: <Widget>[
                    Flexible(
                        child: Text(
                      comments[index].userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    Text(
                      DateFormatter.commentServerTimeFormatter(
                          comments[index].upDatedAt),
                      style: TextStyle(color: Color(0xFFbabbbf), fontSize: 14),
                    )
                  ],
                ),
                subtitle: Container(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.01,
                      MediaQuery.of(context).size.width * 0.01,
                      MediaQuery.of(context).size.width * 0.01,
                      MediaQuery.of(context).size.width * 0.01),
                  child: Text(
                    stringToEmoji(comments[index].message),
                    style: TextStyle(color: Color(0xFFbabbbf)),
                  ),
                ),
                trailing: comments[index].myComment == true
                    ? PopupMenuButton<CommentsOptions>(
                        color: Color(0xFF2a2b2f),
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (CommentsOptions option) {
                          if (option == CommentsOptions.delete) {
                            deleteComment(comments[index].id, index);
                          } else {
                            textEditingController.text =
                                stringToEmoji(comments[index].message);
                            commentId = comments[index].id;
                            commentIndex = index;
                            _editCommet = true;
                          }
                        },
                        itemBuilder: (context) =>
                            <PopupMenuEntry<CommentsOptions>>[
                              PopupMenuItem<CommentsOptions>(
                                value: CommentsOptions.edit,
                                child: Text("Edit"),
                              ),
                              PopupMenuItem<CommentsOptions>(
                                value: CommentsOptions.delete,
                                child: Text("Delete"),
                              ),
                            ])
                    : SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget commentSendTextField() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: textEditingController,
              onChanged: (val) {
                if (val.length > 0) {
                  setState(() {
                    comment = val;
                    isWiritng = true;
                  });
                } else {
                  setState(() {
                    isWiritng = false;
                  });
                }
              },
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type Your Comment here",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  // borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                // suffixIcon: GestureDetector(
                //   onTap: (){},
                //   child: Icon(Icons.send,size: 30,color: Theme.of(context).primaryColor,),
                // ),
              ),
            ),
          ),
          isWiritng
              ? Container(
                  margin: EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 28,
                      // color: Color(0xFFbabbbf),
                      color: Theme.of(context).buttonColor,
                      onPressed: () {
                        if (_editCommet == false)
                          createComment(
                              widget.post.id, textEditingController.text);
                        else {
                          updateComment(textEditingController.text);
                        }
                      }),
                )
              : Container(),
        ],
      ),
    );
  }
}
