import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/shared/chat_timestamp.dart';
import 'package:r2a_mobile/shared_state/call_screen.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/FCM_configs.dart';
import 'package:video_player/video_player.dart';
import '../callscreens/call_utilities.dart';
import '../../services/database.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatDetail extends StatefulWidget {
  final String chatRoomId;
  final int userId;
  final String tenantId;
  ChatDetail({this.chatRoomId, this.userId, this.tenantId});

  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  Map<String, String> _paths;
  List images = List();
  File path;
  String imageUrl;
  bool isLoading = false;
  Stream<QuerySnapshot> chats;
  String chatName;
  String chatAvatar;
  Timestamp status;
  Size size;
  TextEditingController messageEditingController;
  final ScrollController listScrollController = ScrollController();
  UserState userState;
  CallScreenState callScreenState;
  String receiverToken;
  @override
  void initState() {
    super.initState();
    DatabaseMethods().getUserById(widget.tenantId).then((userData) {
      setState(() {
        chatName = userData.data['firstName'];
        chatAvatar = userData.data['avatarUrl'];
        status = userData.data['status'];
      });
    });

    listScrollController.addListener(() {});
    messageEditingController = TextEditingController();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageEditingController?.dispose();
  }

  // For Images Selection Only
  void openFileExplorer() async {
    images = [];
    Navigator.pop(context);
    FocusScope.of(context).requestFocus(new FocusNode()); //remove Focus
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.image, allowedExtensions: null);
      if (_paths != null) {
        path = File(_paths.values.toList()[0].toString());
        for (int i = 0; i < _paths.length; i++) {
          int size = File(_paths.values.toList()[i]).lengthSync();
          // totalSize = totalSize + size;
          setState(() {
            images.add(_paths.values.toList()[i]);
          });
        }
      }
      if (images.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        for (int i = 0; i < images.length; i++) {
          uploadFile(i, 1);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  // For Audio Selection Only
  void selectAudio() async {
    Navigator.pop(context);
    images = [];
    FocusScope.of(context).requestFocus(FocusNode()); //remove Focus
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.audio, allowedExtensions: null);
      if (_paths != null) {
        path = File(_paths.values.toList()[0].toString());
        for (int i = 0; i < _paths.length; i++) {
          int size = File(_paths.values.toList()[i]).lengthSync();
          // totalSize = totalSize + size;
          setState(() {
            images.add(_paths.values.toList()[i]);
          });
        }
      }
      if (images.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        for (int i = 0; i < images.length; i++) {
          uploadFile(i, 3);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //For Videos Selection
  void selectVideo() async {
    Navigator.pop(context);
    images = [];
    FocusScope.of(context).requestFocus(FocusNode()); //remove Focus
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.video, allowedExtensions: null);
      path = File(_paths.values.toList()[0].toString());
      for (int i = 0; i < _paths.length; i++) {
        setState(() {
          images.add(_paths.values.toList()[i]);
        });
      }
      if (images.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        for (int i = 0; i < images.length; i++) {
          uploadFile(i, 2);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  final ImagePicker _picker = ImagePicker();
  Future getImageFromCamera() async {
    Navigator.pop(context);
    try {
      final pickedFile =
          await _picker.getImage(source: ImageSource.camera, imageQuality: 60);
      if (pickedFile != null) {
        uploadSingleFile(pickedFile, 1);
      }
    } catch (e) {
      print("image picker error");
    }
  }

  final ImagePicker _videoPicker = ImagePicker();
  Future getVideoFromCamera() async {
    Navigator.pop(context);
    try {
      final pickedFile = await _videoPicker.getVideo(
          source: ImageSource.camera, maxDuration: Duration(minutes: 10));
      if (pickedFile != null) {
        uploadSingleFile(pickedFile, 2);
      }
    } catch (e) {
      print("image picker error");
    }
  }

  Future uploadSingleFile(PickedFile uploadimage, type) async {
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + "${widget.userId}";
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(File(uploadimage.path));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        addMessage(imageUrl, type);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future uploadFile(int index, int type) async {
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + "${widget.userId}";
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(File(images[index]));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        addMessage(imageUrl, type);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<SendMenuItems> menuItems = [
    SendMenuItems(text: "Photos", icons: Icons.image, color: Colors.amber),
    SendMenuItems(
        text: "Videos", icons: Icons.insert_drive_file, color: Colors.purple),
    SendMenuItems(
        text: "Audios", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(text: "Camera", icons: Icons.camera_alt, color: Colors.red),
    SendMenuItems(
        text: "Record Video", icons: Icons.videocam, color: Colors.teal),
  ];
  void showModal() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              height: size.height / 2,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Center(
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.14,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: InkWell(
                            onTap: () => openFileExplorer(),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[0].color.shade100,
                                ),
                                height: size.height * 0.05,
                                width: size.height * 0.05,
                                child: Icon(
                                  menuItems[0].icons,
                                  size: 20,
                                  color: menuItems[0].color.shade700,
                                ),
                              ),
                              title: Text(menuItems[0].text),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: InkWell(
                            onTap: () => selectVideo(),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[1].color.shade100,
                                ),
                                height: size.height * 0.05,
                                width: size.height * 0.05,
                                child: Icon(
                                  menuItems[1].icons,
                                  size: 20,
                                  color: menuItems[1].color.shade400,
                                ),
                              ),
                              title: Text(menuItems[1].text),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: InkWell(
                            onTap: () => selectAudio(),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[2].color.shade100,
                                ),
                                height: size.height * 0.05,
                                width: size.height * 0.05,
                                child: Icon(
                                  menuItems[2].icons,
                                  size: 20,
                                  color: menuItems[2].color.shade400,
                                ),
                              ),
                              title: Text(menuItems[2].text),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: InkWell(
                            onTap: () => getImageFromCamera(),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[3].color.shade100,
                                ),
                                height: size.height * 0.05,
                                width: size.height * 0.05,
                                child: Icon(
                                  menuItems[3].icons,
                                  size: 20,
                                  color: menuItems[3].color.shade400,
                                ),
                              ),
                              title: Text(menuItems[3].text),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: InkWell(
                            onTap: () => getVideoFromCamera(),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[4].color.shade100,
                                ),
                                height: size.height * 0.05,
                                width: size.height * 0.05,
                                child: Icon(
                                  menuItems[4].icons,
                                  size: 20,
                                  color: menuItems[4].color.shade400,
                                ),
                              ),
                              title: Text(menuItems[4].text),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> requestPermission(List<Permission> permission) async {
    Map<Permission, PermissionStatus> status = await permission.request();
    if (await Permission.camera.isDenied &&
        await Permission.microphone.isDenied) {
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    callScreenState = Provider.of<CallScreenState>(context, listen: true);
    size = MediaQuery.of(context).size;
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
              ),
              SizedBox(
                width: size.width * 0.02,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/user_profile',
                      arguments: widget.tenantId);
                },
                child: chatAvatar != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(chatAvatar),
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                      ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/user_profile',
                          arguments: widget.tenantId);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$chatName",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StreamBuilder<DocumentSnapshot>(
                          stream: DatabaseMethods()
                              .getUserStatusId(widget.tenantId),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return Text('');
                                break;
                              case ConnectionState.waiting:
                                return Text(
                                  'Loading..',
                                  style: Theme.of(context).textTheme.caption,
                                );
                                break;
                              default:
                                var now = new DateTime.now();
                                DateTime utc = DateTime.parse(snapshot
                                    .data['status']
                                    .toDate()
                                    .toString());
                                DateTime date = utc.toLocal();
                                Duration diff = now.difference(date);
                                receiverToken = snapshot.data['pushToken'];
                                return diff.inMinutes < 3
                                    ? Text(
                                        "online",
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      )
                                    : Text(
                                        "${ChatTime.serverTimeFormatter(snapshot.data['status'].toDate().toString())}",
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      );
                            }
                          },
                        )
                      ],
                    )),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.video_call,
              ),
              onPressed: callScreenState.isCallDailed
                  ? null
                  : () async => await requestPermission(
                          [Permission.camera, Permission.microphone])
                      ? chatVideoCall()
                      // CallUtils.dial(
                      //     tenantId: widget.tenantId,
                      //     tenantName: chatName,
                      //     tenantPic: chatAvatar,
                      //     userId: widget.userId,
                      //     userName: userState.userName,
                      //     userPic: userState.avatar,
                      //     channelId: widget.chatRoomId,
                      //     context: context,
                      //     isVideoCall: true,
                      //   )
                      : print("vide call error"),
            ),
            IconButton(
              icon: Icon(
                Icons.phone,
              ),
              onPressed: callScreenState.isCallDailed
                  ? null
                  : () async => await requestPermission(
                          [Permission.camera, Permission.microphone])
                      ? chatAudioCall()
                      // CallUtils.dial(
                      //     tenantId: widget.tenantId,
                      //     tenantName: chatName,
                      //     tenantPic: chatAvatar,
                      //     userId: widget.userId,
                      //     userName: userState.userName,
                      //     userPic: userState.avatar,
                      //     channelId: widget.chatRoomId,
                      //     context: context,
                      //     isVideoCall: false)
                      : print("vide call error"),
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(child: chatMessages()),
                inputMessage(),
              ],
            ),
            loading(),
          ],
        ),
      ),
    );
  }

  void chatVideoCall() {
    sendCallNotification("Video Call", userState.userName);
    callScreenState.updateIsCallDailled = true;
    CallUtils.dial(
      tenantId: widget.tenantId,
      tenantName: chatName,
      tenantPic: chatAvatar,
      userId: widget.userId,
      userName: userState.userName,
      userPic: userState.avatar,
      channelId: widget.chatRoomId,
      context: context,
      isVideoCall: true,
    );
  }

  void chatAudioCall() {
    sendCallNotification("Audio Call", userState.userName);
    callScreenState.updateIsCallDailled = true;
    CallUtils.dial(
        tenantId: widget.tenantId,
        tenantName: chatName,
        tenantPic: chatAvatar,
        userId: widget.userId,
        userName: userState.userName,
        userPic: userState.avatar,
        channelId: widget.chatRoomId,
        context: context,
        isVideoCall: false);
  }

  Widget loading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
              color: Colors.white.withOpacity(0.6),
            )
          : Container(),
    );
  }

  Widget inputMessage() {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () => showModal(),
            child: Container(
              margin: EdgeInsets.all(2),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: messageEditingController,
              minLines: 1,
              maxLines: 4,
              // keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Type a Message",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            child: RawMaterialButton(
              onPressed: () {
                addMessage(messageEditingController.text, 0);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
              fillColor: Theme.of(context).buttonColor,
              shape: CircleBorder(),
              elevation: 0.0,
            ),
            constraints: BoxConstraints(
              maxWidth: 40,
              maxHeight: 40,
            ),
          )
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (var data in snapshot.data.documents) {
            if (data['seen'] == false) {
              if (data['receiverId'].toString() == widget.userId.toString()) {
                if (data.reference != null) {
                  Firestore.instance
                      .runTransaction((Transaction myTransaction) async {
                    await myTransaction.update(data.reference, {'seen': true});
                  });
                }
              }
            }
          }
        }

        return snapshot.hasData
            ? ListView.builder(
                controller: listScrollController,
                addAutomaticKeepAlives: true,
                key: UniqueKey(),
                shrinkWrap: true,
                reverse: true,
                cacheExtent: 1000,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      MessageTile(
                        key: PageStorageKey(UniqueKey()),
                        message: snapshot.data.documents[index].data["content"],
                        sendByMe: widget.userId ==
                            int.parse(snapshot
                                .data.documents[index].data["senderId"]),
                        timeStamp:
                            snapshot.data.documents[index].data["timestamp"],
                        contentType:
                            snapshot.data.documents[index].data["contentType"],
                        seen: snapshot.data.documents[index].data["seen"],
                      ),
                    ],
                  );
                })
            : Container();
      },
    );
  }

  addMessage(String content, int type) {
    if (content.trim() != '') {
      Map<String, dynamic> chatMessageMap = {
        "senderId": "${widget.userId}",
        "receiverId": "${widget.tenantId}",
        "content": content,
        "timestamp": DateTime.now().toUtc(),
        "contentType": "$type",
        "groupId": "${widget.chatRoomId}",
        "seen": false
      };
      if (type == 0) {
        sendFcmMessage(userState.userName, content);
      } else if (type == 1) {
        sendFcmMessage(userState.userName, "📷 Image");
      } else if (type == 2) {
        sendFcmMessage(userState.userName, "🎬 Video");
      } else if (type == 3) {
        sendFcmMessage(userState.userName, "🔊 Audio");
      } else {
        sendFcmMessage(userState.userName, "📂 File");
      }
      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => messageEditingController.clear());
      DatabaseMethods().updateGroupTimeStamp(widget.chatRoomId, content, type);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<bool> sendCallNotification(String title, String message) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "to": "$receiverToken",
        "notification": {"title": "$title", "body": "$message"},
        "priority": 10
      };
      var client = new Client();
      var response =
          await client.post(url, headers: header, body: jsonEncode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  Future<bool> sendFcmMessage(String title, String message) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "to": "$receiverToken",
        "notification": {"title": "$title", "body": "$message"},
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "chat": {
            "chat_room_id": "${widget.chatRoomId}",
            "user_id": "${widget.tenantId}",
            "recevier_id": "${widget.userId}"
          }
        },
        "priority": 10
      };
      var client = new Client();
      var response =
          await client.post(url, headers: header, body: jsonEncode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }
}

class MessageTile extends StatelessWidget {
  final String contentType;
  final String message;
  final bool sendByMe;
  final Timestamp timeStamp;
  final bool seen;

  const MessageTile(
      {Key key,
      this.contentType,
      @required this.message,
      @required this.sendByMe,
      this.timeStamp,
      this.seen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return contentType == "0"
        ? Container(
            padding: EdgeInsets.only(
                top: size.width * 0.002,
                bottom: size.width * 0.02,
                left: sendByMe ? 0 : size.width * 0.03,
                right: sendByMe ? size.width * 0.03 : 0),
            alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment:
                  sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "${ChatTime.serverTimeFormatter(timeStamp.toDate().toString())}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Container(
                  margin: sendByMe
                      ? EdgeInsets.only(left: size.width * 0.15)
                      : EdgeInsets.only(right: size.width * 0.15),
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * 0.02,
                      horizontal: size.width * 0.03),
                  // padding:
                  //     EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: sendByMe
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).backgroundColor,
                    borderRadius: sendByMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                            bottomLeft: Radius.circular(23))
                        : BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                            bottomRight: Radius.circular(23)),
                  ),
                  child: sendByMe
                      ? Text(message,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: sendByMe ? Colors.white : Colors.black,
                            fontSize: 16,
                            // fontFamily: 'OverpassRegular',
                            fontWeight: FontWeight.w300,
                          ))
                      : Text(message,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            // color: sendByMe ? Colors.white : Colors.black,
                            fontSize: 16,
                            // fontFamily: 'OverpassRegular',
                            fontWeight: FontWeight.w300,
                          )),
                ),
                sendByMe
                    ? seen
                        ? Text(
                            "seen",
                            style: Theme.of(context).textTheme.caption,
                          )
                        : SizedBox.shrink()
                    : SizedBox.shrink(),
                // Icon(Icons.done_all,size: 19,)
              ],
            ),
          )
        : contentType == "1"
            ? Container(
                padding: EdgeInsets.only(
                    top: size.width * 0.002,
                    bottom: size.width * 0.02,
                    left: sendByMe ? 0 : size.width * 0.03,
                    right: sendByMe ? size.width * 0.03 : 0),
                alignment:
                    sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: sendByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        "${ChatTime.serverTimeFormatter(timeStamp.toDate().toString())}",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.caption.color),
                      ),
                    ),
                    Container(
                      child: FlatButton(
                        child: Material(
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
                              child: Text("error!"),
                              // child: Image.asset(
                              //   'images/img_not_available.jpeg',
                              //   width: 200.0,
                              //   height: 200.0,
                              //   fit: BoxFit.cover,
                              // ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: message,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenWrapper(
                                imageProvider: NetworkImage(message),
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(0),
                      ),
                    )
                  ],
                ),
              )
            : contentType == "2"
                ? Container(
                    padding: EdgeInsets.only(
                        top: size.width * 0.002,
                        bottom: size.width * 0.02,
                        left: sendByMe ? 0 : size.width * 0.03,
                        right: sendByMe ? size.width * 0.03 : 0),
                    alignment:
                        sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: sendByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "${ChatTime.serverTimeFormatter(timeStamp.toDate().toString())}",
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color),
                          ),
                        ),
                        Container(
                          child: FlatButton(
                            child: Material(
                              child: VideoPlayerApp(
                                url: message,
                                key: UniqueKey(),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              // Navigator.push(
                              //     context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                            },
                            padding: EdgeInsets.all(0),
                          ),
                        )
                      ],
                    ),
                  )
                : contentType == "3"
                    ? Container(
                        padding: EdgeInsets.only(
                            top: size.width * 0.002,
                            bottom: size.width * 0.02,
                            left: sendByMe ? 0 : size.width * 0.03,
                            right: sendByMe ? size.width * 0.03 : 0),
                        alignment: sendByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: sendByMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3),
                              child: Text(
                                "${ChatTime.serverTimeFormatter(timeStamp.toDate().toString())}",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .color),
                              ),
                            ),
                            Container(
                              child: FlatButton(
                                child: Material(
                                  child: AudioPlayChat(
                                    url: message,
                                    key: UniqueKey(),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  // Navigator.push(
                                  //     context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                                },
                                padding: EdgeInsets.all(0),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container();
  }
}

class SendMenuItems {
  String text;
  IconData icons;
  MaterialColor color;
  SendMenuItems({@required this.text, @required this.icons, this.color});
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
    // _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {

  // return FutureBuilder(
  //     future: _initializeVideoPlayerFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         return new Container(

  //           child: Card(
  //           key: new PageStorageKey(widget.url),
  //             elevation: 5.0,
  //             child: Column(
  //               children: <Widget>[
  //               Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Chewie(
  //                     key: new PageStorageKey(widget.url),
  //                     controller: ChewieController(
  //                       videoPlayerController: videoPlayerController,
  //                       aspectRatio: 3 / 2,
  //                       // Prepare the video to be played and display the first frame
  //                       autoInitialize: true,
  //                       looping: false,
  //                       autoPlay: false,
  //                       // Errors can occur for example when trying to play a video
  //                      // from a non-existent URL
  //                       errorBuilder: (context, errorMessage) {
  //                         return Center(
  //                           child: Text(
  //                             errorMessage,
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 ],
  //             ),
  //           ),
  //         );
  //       }
  //       else {
  //         return Center(
  //           child: CircularProgressIndicator(),);
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
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

enum PlayerState { stopped, playing, paused }

class AudioPlayChat extends StatefulWidget {
  final String url;

  const AudioPlayChat({Key key, this.url}) : super(key: key);
  @override
  _AudioPlayChatState createState() => _AudioPlayChatState();
}

class _AudioPlayChatState extends State<AudioPlayChat>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  bool playing = false;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    _animationController.dispose();
    super.dispose();
  }

  void initAudioPlayer() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(widget.url);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  void _handleOnPressed() {
    setState(() {
      // isPlaying = !isPlaying;
      isPlaying ? pause() : play();
      isPlaying
          ? _animationController.reverse()
          : _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Material(child: buildPlayer()),
    );
  }

  Widget buildPlayer() => Container(
        child: Row(
          children: [
            // IconButton(
            //   onPressed: _handleOnPressed,
            //   iconSize: MediaQuery.of(context).size.width * 0.1,
            //   icon: AnimatedIcon(
            //     icon: AnimatedIcons.play_pause,
            //     progress: _animationController,
            //   ),
            //   color: Theme.of(context).primaryColor,
            // ),
            InkWell(
              onTap: _handleOnPressed,
              child: AnimatedIcon(
                color: Theme.of(context).primaryColor,
                size: MediaQuery.of(context).size.width * 0.1,
                icon: AnimatedIcons.play_pause,
                progress: _animationController,
              ),
            ),
            Slider(
                value: position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) {
                  return audioPlayer.seek((value / 1000).roundToDouble());
                },
                min: 0.0,
                max: duration?.inMilliseconds?.toDouble() ?? 1),
            //         Text(
            //        "${positionText ?? ''} / ${durationText ?? ''}",
            //       // duration != null ? durationText : '',
            //   style: TextStyle(fontSize: 24.0),
            // ),
          ],
        ),
      );
}

class FullScreenWrapper extends StatelessWidget {
  const FullScreenWrapper({
    this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingBuilder: loadingBuilder,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          basePosition: basePosition,
          filterQuality: filterQuality,
        ),
      ),
    );
  }
}
