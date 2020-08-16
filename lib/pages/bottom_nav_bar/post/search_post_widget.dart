import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/post_comments.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/date_time_format.dart';
import 'package:r2a_mobile/utils/emoji_decode.dart';

class SearchPost extends StatefulWidget {
  final PostModel post;
  final int index;

  const SearchPost({Key key, this.post, this.index}) : super(key: key);

  @override
  _SearchPostState createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  final categories = {1: "Social", 2: "Medical", 3: "R2A News", 4: "News Feed"};
  PageController pageController;
  var config; //App config varaible
  final storage = new FlutterSecureStorage();
  List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = [true, false];
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Container(
        decoration: BoxDecoration(
          border: widget.post.status
              ? Border.all(
                  color: Colors.green,
                  width: 2,
                )
              : Border(),
          // boxShadow: [
          //   BoxShadow(
          //     color: Theme.of(context).textTheme.caption.color.withOpacity(0.2),
          //     spreadRadius: 2,
          //     blurRadius: 5,
          //     offset: Offset(0, 2),
          //   ),
          // ],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
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
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinglePost(
                          post: widget.post,
                          index: widget.index,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${stringToEmoji(widget.post.description)}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .color,
                                    height: 1.4,
                                    letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // Spacer(flex: 1,),
                        widget.post.attachments.length == 0
                            ? SizedBox.shrink()
                            : Column(
                                children: <Widget>[
                                  Image.network(
                                    widget.post.attachments[0]['attachment'],
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: Text(
                          "${widget.post.likesCount} Likes",
                          style: TextStyle(
                              color: Theme.of(context).textTheme.caption.color),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PostComments(
                                    post: widget.post,
                                  )));
                        },
                        child: Text(
                          "${widget.post.commentsCount} Comments",
                          style: TextStyle(
                              color: Theme.of(context).textTheme.caption.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget imageCarosole() {
    final _controller = new PageController();

    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: widget.post.attachments.length,
            itemBuilder: (context, index) {
              return Container();
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.009,
        ),
        Container(
          child: Center(),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
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
                      color: Colors.white,
                      height: 1.4,
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
                CustomButtons(
                  color: Colors.grey,
                  label: "Share",
                  iconData: Icons.share,
                ),
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

class CustomButtons extends StatelessWidget {
  final Color color;
  final IconData iconData;
  final String label;

  const CustomButtons({Key key, this.color, this.iconData, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              color: color,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
