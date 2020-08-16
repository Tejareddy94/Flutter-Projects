import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/read_more_text.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/date_time_format.dart';
import 'package:r2a_mobile/utils/emoji_decode.dart';
import 'package:video_player/video_player.dart';
import 'edit_posts_page.dart';
import 'post_comments.dart';
import 'dart:math';

class PostsWidget extends StatefulWidget {
  final PostModel post;
  final void Function(int id, int index) deletePost;
  final void Function(int id, int index) singleDeletepost;
  final int index;
  PostsWidget(
      {Key key, this.post, this.deletePost, this.index, this.singleDeletepost})
      : super(key: key);
  @override
  _PostsWidgetState createState() => _PostsWidgetState();
}

enum EditOptions { edit, delete, status }

class _PostsWidgetState extends State<PostsWidget> {
  final categories = {1: "Social", 2: "Medical", 3: "R2A News", 4: "News Feed"};
  PageController pageController;
  var config; //App config varaible
  final storage = new FlutterSecureStorage();
  List<bool> isSelected;
  String role = "";
  @override
  void initState() {
    super.initState();
    setRole();
    isSelected = [true, false];
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
    });
    pageController =
        PageController(initialPage: 0, keepPage: true, viewportFraction: 0.8);
  }

  void setRole() {
    if (widget.post.user.admin) {
      role = 'Admin';
    } else if (widget.post.user.role == 1) {
      role = "Political Representative";
    } else if (widget.post.user.role == 2) {
      role = "Medical Representative";
    }
  }

  Future fetchLikeDislike(int id) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/generate_like_dislike/$id',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
      } else {
        print("something went worng status code ${response.statusCode}");
      }
    } catch (err) {
      print(err);
    }
  }

  Future toggleClarified(bool toggle) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/toggle_post_clarified/${widget.post.id}',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        setState(() {
          widget.post.status = toggle;
        });
      } else {
        print("something went worng status code ${response.statusCode}");
      }
    } catch (e) {}
  }

  showAlertDialog(BuildContext context) {
    bool toggleValue = widget.post.status;

    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.white70),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(
                "Change Status",
                style: TextStyle(color: Theme.of(context).textSelectionColor),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Toggle this post's status",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Text("Status"),
                              ),
                            ),
                            Text(
                              "Mark the post solved/unsolved",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          height: 40,
                          width: 90,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: toggleValue
                                  ? Colors.greenAccent[100]
                                  : Colors.redAccent[100].withOpacity(0.5)),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                toggleValue = !toggleValue;
                              });
                              toggleClarified(toggleValue);
                            },
                            child: Stack(
                              children: <Widget>[
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  top: 3.0,
                                  left: toggleValue ? 50.0 : 0.0,
                                  right: toggleValue ? 0.0 : 50.0,
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: toggleValue
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 30,
                                            key: UniqueKey(),
                                          )
                                        : Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                            size: 30,
                                            key: UniqueKey(),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                cancelButton,
              ],
            );
          },
        );
      },
    );
  }

  Widget statusMenu() {
    return PopupMenuButton<EditOptions>(
        color: Color(0xFF2a2b2f),
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).textSelectionColor,
        ),
        onSelected: (EditOptions option) {
          if (option == EditOptions.status) {
            showAlertDialog(context);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<EditOptions>>[
              PopupMenuItem<EditOptions>(
                value: EditOptions.status,
                child: Text("Status"),
              ),
            ]);
  }

  Widget newsFeedMenu() {
    return PopupMenuButton<EditOptions>(
        color: Theme.of(context).popupMenuTheme.color,
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).iconTheme.color,
        ),
        onSelected: (EditOptions option) {
          if (option == EditOptions.delete) {
            DeletePostAlertBox alert = DeletePostAlertBox(
              widget.deletePost,
              widget.index,
              widget.post.id,
            );
            alert.showAlertDialog(context);
            // widget.deletePost(widget.post.id, widget.index);
          } else if (option == EditOptions.status) {
            showAlertDialog(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditPosts(
                          post: widget.post,
                        )));
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<EditOptions>>[
              PopupMenuItem<EditOptions>(
                value: EditOptions.edit,
                child: Text("Edit"),
              ),
              PopupMenuItem<EditOptions>(
                value: EditOptions.delete,
                child: Text("Delete"),
              ),
            ]);
  }

  Widget userMenu() {
    return PopupMenuButton<EditOptions>(
        color: Theme.of(context).popupMenuTheme.color,
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).iconTheme.color,
        ),
        onSelected: (EditOptions option) {
          if (option == EditOptions.delete) {
            DeletePostAlertBox alert = DeletePostAlertBox(
              widget.deletePost,
              widget.index,
              widget.post.id,
            );
            alert.showAlertDialog(context);
            // widget.deletePost(widget.post.id, widget.index);
          } else if (option == EditOptions.status) {
            showAlertDialog(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditPosts(
                          post: widget.post,
                        )));
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<EditOptions>>[
              PopupMenuItem<EditOptions>(
                value: EditOptions.edit,
                child: Text("Edit"),
              ),
              PopupMenuItem<EditOptions>(
                value: EditOptions.status,
                child: Text("Status"),
              ),
              PopupMenuItem<EditOptions>(
                value: EditOptions.delete,
                child: Text("Delete"),
              ),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Column(
        children: [
          // Container(
          //   color: Colors.white,
          //   child: Padding(
          //     padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text("Admin"),
          //         Container(
          //           // margin: EdgeInsets.all(5),
          //           padding: EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             border: Border.all(color: Theme.of(context).buttonColor),
          //           ),
          //           child: Text(
          //             categories[widget.post.category],
          //             style: TextStyle(color: Theme.of(context).buttonColor),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // widget.post.status
          //     ? Padding(
          //         padding: EdgeInsets.symmetric(
          //             horizontal: MediaQuery.of(context).size.width * 0.01),
          //         child: Align(
          //             alignment: Alignment.topRight,
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.green,
          //               ),
          //               padding: EdgeInsets.all(5),
          //               child: Text(
          //                 "Solved",
          //                 style: TextStyle(color: Colors.white),
          //               ),
          //             )),
          //       )
          //     : SizedBox.shrink(),
          Container(
            decoration: BoxDecoration(
              border: widget.post.status
                  ? Border.all(
                      color: Colors.green,
                      width: 2,
                    )
                  : Border(),
              // boxShadow: [
              //   BoxShadow(
              //     color: Theme.of(context)
              //         .textTheme
              //         .caption
              //         .color
              //         .withOpacity(0.2),
              //     spreadRadius: 1,
              //     blurRadius: 5,
              //     offset: Offset(0, 2),
              //   ),
              // ],
              color: Theme.of(context).cardColor,
              // color: (widget.post.user.role == 1 ||
              //         widget.post.user.role == 2 ||
              //         widget.post.user.admin == true)
              //     ? Theme.of(context).cardTheme.color
              //     : Theme.of(context).appBarTheme.color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.width * 0.01,
                      bottom: MediaQuery.of(context).size.width * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                    ],
                  ),
                ),
                // Divider(
                //   height: 7,
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: 0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/user_profile',
                              arguments: widget.post.userId);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.12,
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: widget.post.userAvatar == ""
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade400,
                                  child: Text(
                                    widget.post.user.firstname[0].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(widget.post.userAvatar),
                                  backgroundColor: Colors.grey.shade400,
                                ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.017,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/user_profile',
                                    arguments: widget.post.userId);
                              },
                              child: Text(
                                "${widget.post.user.firstname}",
                                style: Theme.of(context).textTheme.headline5,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            widget.post.user.admin
                                ? SizedBox.shrink()
                                : widget.post.category == 1
                                    ? Text(
                                        "${widget.post.constituencyDetails.constituency}, ${widget.post.constituencyDetails.district}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color),
                                      )
                                    : SizedBox.shrink(),
                            widget.post.user.admin
                                ? SizedBox.shrink()
                                : widget.post.category == 2
                                    ? Text(
                                        "${widget.post.districtDetails.district}, ${widget.post.districtDetails.state}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color),
                                      )
                                    : SizedBox.shrink(),
                            Row(
                              children: <Widget>[
                                Text(
                                  DateFormatter.serverTimeFormatter(
                                      widget.post.updateDate),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                Icon(
                                  Icons.history,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                  size: 17,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          (widget.post.category == 3 ||
                                  widget.post.category == 4)
                              ? Row(
                                  children: [
                                    (widget.post.myPost)
                                        ? newsFeedMenu()
                                        : SizedBox.shrink(),
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    // Container(
                                    //   // margin: EdgeInsets.all(5),
                                    //   padding: EdgeInsets.all(5),
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(10),
                                    //     // border: Border.all(
                                    //     //     color: Theme.of(context).buttonColor),
                                    //   ),
                                    //   child: Text(
                                    //     categories[widget.post.category],
                                    //     // style: TextStyle(
                                    //     //     color: Theme.of(context).textTheme.caption.color),
                                    //   ),
                                    // ),
                                    // widget.post.status
                                    //     ? Text("Solved")
                                    //     : Text(
                                    //         "UnSolved",
                                    //       ),
                                    widget.post.status
                                        ? Tooltip(
                                            message: "Solved",
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ))
                                        : Tooltip(
                                            message: 'Unsolved',
                                            child: Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                          ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Theme.of(context).buttonColor),
                                      ),
                                      child: Text(
                                        categories[widget.post.category],
                                        style: TextStyle(
                                            color: Theme.of(context).buttonColor),
                                      ),
                                    ),
                                    (widget.post.myPost ||
                                            widget.post.myDistrictPost ||
                                            widget.post.myConstituencyPost)
                                        ? ((widget.post.myDistrictPost ==
                                                        true &&
                                                    widget.post.myPost ==
                                                        false) ||
                                                (widget.post.myConstituencyPost ==
                                                        true &&
                                                    widget.post.myPost ==
                                                        false))
                                            ? statusMenu()
                                            : (widget.post.myPost)
                                                ? userMenu()
                                                : SizedBox.shrink()
                                        : SizedBox.shrink(),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePost(
                              post: widget.post,
                              deletePost: widget.singleDeletepost,
                              index: widget.index,
                              showDialog: showAlertDialog,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ReadMoreText(
                            stringToEmoji(widget.post.description),
                            trimLines: 3,
                            colorClickableText: Colors.blue[400],
                            trimMode: TrimMode.Line,
                            trimCollapsedText: '...Read More',
                            trimExpandedText: ' Read less',
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  Theme.of(context).textTheme.bodyText2.color,
                              height: 1.4,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.post.attachments.length == 0
                        ? Container()
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                                aspectRatio: 16 / 9, child: imageCarosole())),
                    Divider(
                      height: 7,
                    ),
                    Padding(
                      padding:  EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.post.isLiked = !widget.post.isLiked;
                                widget.post.isLiked
                                    ? widget.post.likesCount++
                                    : widget.post.likesCount--;
                                fetchLikeDislike(widget.post.id);
                              });
                            },
                            child: CustomButtons(
                              color: widget.post.isLiked
                                  ? Theme.of(context).buttonColor
                                  : Colors.grey,
                              label: widget.post.likesCount.toString(),
                              iconData: Icons.thumb_up,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostComments(
                                        post: widget.post,
                                      )));
                            },
                            child: CustomButtons(
                              color: Colors.grey,
                              label: widget.post.commentsCount.toString(),
                              iconData: Icons.insert_comment,
                            ),
                          ),
                          // CustomButtons(
                          //   color: Colors.grey,
                          //   label: "Share",
                          //   iconData: Icons.share,
                          // ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageCarosole() {
    final _controller = new PageController();

    const _kDuration = const Duration(milliseconds: 300);

    const _kCurve = Curves.ease;
    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: widget.post.attachments.length,
            itemBuilder: (context, index) {
              return Container(
                // width: MediaQuery.of(context).size.width,
                // width: MediaQuery.of(context).size.width * 7,
                // height: MediaQuery.of(context).size.width * 0.7,
                child: Classify(
                  widget: widget,
                  index: index,
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.009,
        ),
        Container(
          child: new Center(
            child: new SliderDots(
              controller: _controller,
              itemCount: widget.post.attachments.length,
              onPageSelected: (int page) {
                _controller.animateToPage(
                  page,
                  duration: _kDuration,
                  curve: _kCurve,
                );
              },
              color: Color(0xFFbabbbf),
            ),
          ),
        ),
      ],
    );
  }
}

class SliderDots extends AnimatedWidget {
  SliderDots({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);
  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;
  static const double _kDotSize = 6.0;
  static const double _kMaxZoom = 2.0;
  static const double _kDotSpacing = 20.0;
  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}

class Classify extends StatefulWidget {
  const Classify({
    Key key,
    @required this.widget,
    this.index,
  }) : super(key: key);

  final PostsWidget widget;
  final int index;

  @override
  _ClassifyState createState() => _ClassifyState();
}

class _ClassifyState extends State<Classify>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  VideoProgressColors colors = VideoProgressColors(
      bufferedColor: Color.fromRGBO(50, 50, 200, 0.2),
      backgroundColor: Color.fromRGBO(200, 200, 200, 0.5),
      playedColor: Color.fromRGBO(247, 58, 242, 0.7));

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween<double>(begin: -20, end: 0).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.widget.post.attachments[widget.index]['file_type'] == 1
        ? Stack(
            children: <Widget>[
              // Center(child: CircularProgressIndicator()),
              Center(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Image.asset(
                      'images/img_not_available.jpeg',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: widget.widget.post.attachments[widget.index]
                      ['attachment'],
                  // width: 200.0,
                  // height: 200.0,
                  fit: BoxFit.cover,
                ),
                // child: FadeInImage.assetNetwork(
                //   placeholder: 'assets/images/output-onlinepngtools.png',
                //   width: MediaQuery.of(context).size.width,
                //   image: widget.widget.post.attachments[widget.index]
                //       ['attachment'],
                //   fit: BoxFit.cover,
                // ),
              ),
            ],
          )
        : VideoPlayerApp(
            url: widget.widget.post.attachments[widget.index]['attachment'],
            key: UniqueKey(),
          );
  }
}

class VideoPlayerApp extends StatefulWidget {
  final String url;
  const VideoPlayerApp({Key key, this.url}) : super(key: key);
  @override
  _VideoPlayerAppState createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    print("video disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            _PlayPauseOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class CustomButtons extends StatelessWidget {
  final Color color;
  final IconData iconData;
  final String label;

  const CustomButtons({Key key, this.color, this.iconData, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              color: color,
              size: 23,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Likes extends StatelessWidget {
  final Color color;
  final IconData iconData;

  const Likes({Key key, this.color, this.iconData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.04,
      width: MediaQuery.of(context).size.height * 0.04,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).textSelectionColor),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 15,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}

class SinglePost extends StatefulWidget {
  final PostModel post;
  final void Function(int id, int index) deletePost;
  final int index;
  final void Function(BuildContext context) showDialog;
  SinglePost({Key key, this.post, this.deletePost, this.index, this.showDialog})
      : super(key: key);

  @override
  _SinglePostState createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  final categories = {1: "Social", 2: "Medical", 3: "R2A News", 4: "News Feed"};
  PageController pageController;
  final storage = new FlutterSecureStorage();
  var config; //App config varaible
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
    });
    pageController =
        PageController(initialPage: 0, keepPage: true, viewportFraction: 0.8);
  }

  Future fetchLikeDislike(int id) async {
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.get(
          '/api/generate_like_dislike/$id',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
      } else {
        print("something went worng status code ${response.statusCode}");
      }
    } catch (err) {
      print(err);
    }
  }

  Widget statusMenu() {
    return PopupMenuButton<EditOptions>(
        color: Theme.of(context).popupMenuTheme.color,
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).iconTheme.color,
        ),
        onSelected: (EditOptions option) {
          if (option == EditOptions.status) {
            widget.showDialog(context);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<EditOptions>>[
              PopupMenuItem<EditOptions>(
                value: EditOptions.status,
                child: Text("Status"),
              ),
            ]);
  }

  Widget userMenu() {
    return PopupMenuButton<EditOptions>(
        color: Theme.of(context).popupMenuTheme.color,
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).iconTheme.color,
        ),
        onSelected: (EditOptions option) {
          if (option == EditOptions.delete) {
            DeletePostAlertBox alert = DeletePostAlertBox(
              widget.deletePost,
              widget.index,
              widget.post.id,
            );
            alert.showAlertDialog(context);
            // widget.deletePost(widget.post.id, widget.index);
          } else if (option == EditOptions.status) {
            widget.showDialog(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditPosts(
                          post: widget.post,
                        )));
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<EditOptions>>[
              PopupMenuItem<EditOptions>(
                value: EditOptions.edit,
                child: Text("Edit"),
              ),
              PopupMenuItem<EditOptions>(
                value: EditOptions.status,
                child: Text("Status"),
              ),
              PopupMenuItem<EditOptions>(
                value: EditOptions.delete,
                child: Text("Delete"),
              ),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Post"),
        actions: <Widget>[
          (widget.post.myPost ||
                  widget.post.myDistrictPost ||
                  widget.post.myConstituencyPost)
              ? ((widget.post.myDistrictPost == true &&
                          widget.post.myPost == false) ||
                      (widget.post.myConstituencyPost == true &&
                          widget.post.myPost == false))
                  ? statusMenu()
                  : (widget.post.myPost) ? userMenu() : SizedBox.shrink()
              : SizedBox.shrink(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.12,
                    width: MediaQuery.of(context).size.width * 0.12,
                    child: widget.post.userAvatar == ""
                        ? CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade400,
                            child: Text(
                              widget.post.user.firstname[0].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(widget.post.userAvatar),
                            backgroundColor: Colors.grey.shade400,
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.017,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.post.user.firstname,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.01,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            DateFormatter.serverTimeFormatter(
                                widget.post.updateDate),
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFFb4b5b9)),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                          Icon(
                            Icons.history,
                            color: Color(0xFFb4b5b9),
                            size: 17,
                          )
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          widget.post.status
                              ? Tooltip(
                                  message: "Solved",
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ))
                              : Tooltip(
                                  message: 'Unsolved',
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).buttonColor),
                            ),
                            child: Text(
                              categories[widget.post.category],
                              style: TextStyle(
                                  color: Theme.of(context).buttonColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    stringToEmoji(widget.post.description),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textSelectionColor,
                      height: 0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            listImages(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      widget.post.isLiked = !widget.post.isLiked;
                      widget.post.isLiked
                          ? widget.post.likesCount++
                          : widget.post.likesCount--;
                      fetchLikeDislike(widget.post.id);
                    });
                  },
                  child: CustomButtons(
                    color: widget.post.isLiked ? Colors.blue : Colors.grey,
                    label: widget.post.likesCount.toString(),
                    iconData: Icons.thumb_up,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostComments(
                              post: widget.post,
                            )));
                  },
                  child: CustomButtons(
                    color: Colors.grey,
                    label: widget.post.commentsCount.toString(),
                    iconData: Icons.insert_comment,
                  ),
                ),
                // CustomButtons(
                //   color: Colors.grey,
                //   label: "Share",
                //   iconData: Icons.share,
                // ),
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Widget listImages() {
    return Column(
      children: widget.post.attachments
          .map(
            (item) => Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01),
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item['attachment']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
