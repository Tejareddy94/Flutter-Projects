import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/notification_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/chat_screen/chat.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/medical.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/polls.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/social_post.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'bottom_nav_bar/chat/chat_tab_bar.dart';
import 'bottom_nav_bar/news_feed.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/add_posts.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'drawer/drawer.dart';
import 'main_search/app_bar_search.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final storage = new FlutterSecureStorage();
  Timer timer;
  UserState userState;
  var avatar,
      profileName,
      email,
      phoneNumber,
      userRole,
      bearer,
      canCreate,
      userId;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@drawable/spalsh_logo');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startTimer();
      firebase(context);
    });
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
    }
    if (message.containsKey('notification')) {
      final dynamic notification = message['notification'];
    }
    // Or do other work.
  }

  NotificationAndroid notificationAndroid;
  Chat chatAndroid;
  void firebase(BuildContext context) {
    try {
      if (Platform.isIOS) {
        _firebaseMessaging
            .requestNotificationPermissions(IosNotificationSettings());
      }
      UserState userState = Provider.of<UserState>(context, listen: true);
      print(userState.pushToken);
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          String msg = '';
          String name = '';
          if (Platform.isIOS) {
            msg = message['aps']['alert']['body'];
            name = message['aps']['alert']['title'];
          } else {
            if (message['data'].isNotEmpty) {
              notificationAndroid = NotificationAndroid();
              notificationAndroid = NotificationAndroid.fromJson(message);
              name = notificationAndroid.notification.title;
              msg = notificationAndroid.notification.body;
            } else {
              name = message['notification']['title'];
              msg = message['notification']['body'];
            }
          }
          showNotification(name, msg);
          print("onMessage: $message");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          String msg = '';
          String name = '';
          if (Platform.isIOS) {
            msg = message['aps']['alert']['body'];
            name = message['aps']['alert']['title'];
          } else {
            if (message['data'].isNotEmpty) {
              notificationAndroid = NotificationAndroid();
              notificationAndroid = NotificationAndroid.fromJson(message);
              name = notificationAndroid.notification.title;
              msg = notificationAndroid.notification.body;
            } else {
              name = message['notification']['title'];
              msg = message['notification']['body'];
            }
          }
          showNotification(name, msg);
          print("onResume: $message");
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      );
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {});
    } catch (e) {
      print(e.message);
    }
  }

  showNotification(String name, String message) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, name, message, platform,
        payload: 'payload');
  }

  Future<dynamic> onSelectNotification(String payload) {
    if (notificationAndroid?.data != null &&
        notificationAndroid?.data?.chat != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return ChatDetail(
          chatRoomId: notificationAndroid.data.chat.chatRoomId,
          userId: int.parse(notificationAndroid.data.chat.userId),
          tenantId: notificationAndroid.data.chat.recevierId,
        );
      }));
    } else {
      print("printed");
    }
  }

  void startTimer() {
    UserState userState = Provider.of<UserState>(context, listen: true);
    Firestore.instance
        .collection('users')
        .document("${userState.id}")
        .updateData({
      "status": DateTime.now().toUtc(),
    });
    timer = Timer.periodic(Duration(minutes: 2), (time) {
      if (userState.id != null) {
        Firestore.instance
            .collection('users')
            .document("${userState.id}")
            .updateData({
          "status": DateTime.now().toUtc(),
        });
      }
    });
  }

  int currentIndex = 0;
  final List<Widget> _navItems = [
    NewsFeed(),
    Polls(),
    SocialPosts(),
    MedicalPosts(),
  ];

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Stream<QuerySnapshot> getUnreadMessages(String id) {
    return Firestore.instance
        .collection("message")
        .where('receiverId', isEqualTo: id)
        .where('seen', isEqualTo: false)
        // .getDocuments();
        // .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: userState.avatar != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(userState.avatar),
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                ),
              );
            },
          ),
          title: Row(
            children: [
              // Image.asset('assets/images/logomin.png'),
              // SizedBox(width: MediaQuery.of(context).size.width*0.02,),
              Text('Right To Ask'),
            ],
          ),
          actions: <Widget>[
            // IconButton(
            //     icon: Icon(
            //       Icons.color_lens,
            //       color: Theme.of(context).textTheme.caption.color,
            //     ),
            //     onPressed: () {
            //       Provider.of<ThemeModel>(context).toggleTheme();
            //     }),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Provider.of<SearchResultsState>(context).serachResultsClear();
                  showSearch(context: context, delegate: MainSearch());
                }),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ChatTabBar()));
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: getUnreadMessages(userState.id),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('');
                        break;
                      case ConnectionState.waiting:
                        return Text(
                          '',
                          style: Theme.of(context).textTheme.caption,
                        );
                        break;
                      default:
                        return snapshot.data.documents.length == 0
                            ? SizedBox.shrink()
                            : Positioned(
                                right: 4,
                                // top: 2,
                                child: Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width *
                                          0.013),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    minHeight:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                  ),
                                  child: Text(
                                    '${snapshot.data.documents.length}',
                                    style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .fontSize),
                                  ),
                                ),
                              );
                    }
                  },
                )
              ],
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (userState.canCreate != 'false') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddPosts()));
            } else {
              showDialog(
                context: context,
                builder: (_) => CustomAlertRoundedBox(
                  message:
                      "Sorry You dont have enough permissions to create post please contact Admin",
                ),
              );
            }
          },
          tooltip: 'Add Post',
          // child: FaIcon(
          //   FontAwesomeIcons.edit,
          //   size: 20,
          //   // color: Theme.of(context).primaryColor,
          // ),
          child: Icon(
            Icons.add,
            // size: 30,
          ),
          elevation: 10.0,
        ),
        // backgroundColor: Theme.of(context).backgroundColor,
        body: IndexedStack(
          children: _navItems,
          index: currentIndex,
        ),
        // bottomNavigationBar: BottomNavigationBar(

        //   // backgroundColor: Colors.white,
        //   // selectedItemColor: Color(0xFF535bec),
        //   // unselectedItemColor: Colors.grey[800],
        //   // elevation: 1,
        //   // unselectedIconTheme: IconThemeData(
        //   //   color: Colors.grey[600],
        //   // ),
        //   // selectedIconTheme: IconThemeData(
        //   //   color: Color(0xFF535bec),
        //   // ),
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: FaIcon(
        //         FontAwesomeIcons.home,
        //         size: 18,
        //       ),
        //       title: Text('Feed'),
        //     ),
        //     // BottomNavigationBarItem(
        //     //   icon: Icon(
        //     //     FontAwesomeIcons.comment,
        //     //     size: 18,
        //     //   ),
        //     //   title: Text('Chats'),
        //     // ),
        //     BottomNavigationBarItem(
        //       icon: FaIcon(
        //         FontAwesomeIcons.users,
        //         size: 18,
        //       ),
        //       title: Text('Social'),
        //     ),
        //     BottomNavigationBarItem(
        //       icon: FaIcon(
        //         FontAwesomeIcons.heartbeat,
        //         size: 18,
        //       ),
        //       title: Text('Medical'),
        //     ),
        //   ],
        //   currentIndex: currentIndex,
        //   onTap: onTapped,
        // ),
        bottomNavigationBar: FABBottomAppBar(
          onTabSelected: onTapped,
          notchedShape: CircularNotchedRectangle(),
          color: Theme.of(context).bottomAppBarColor,
          selectedColor: Theme.of(context).textSelectionColor,
          backgroundColor: Theme.of(context).appBarTheme.color,
          items: [
            FABBottomAppBarItem(
              iconData: Icons.content_copy,
              text: 'News Feed',
              // iconSize: 20,
            ),
            FABBottomAppBarItem(
              iconData: Icons.poll,
              text: 'Polls',
              // iconSize: 20,
            ),
            FABBottomAppBarItem(
              iconData: Icons.perm_contact_calendar,
              text: 'Social',
              // iconSize: 20,
            ),
            FABBottomAppBarItem(
              iconData: Icons.local_hospital,
              text: 'Medical',
              // iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class FABBottomAppBarItem {
  FABBottomAppBarItem({this.iconData, this.text, this.iconSize});
  IconData iconData;
  String text;
  double iconSize;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height: 60.0,
    // this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }
  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  // final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              widget.centerItemText ?? '',
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FABBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: item.iconSize),
                Text(
                  item.text,
                  style: TextStyle(color: color),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
