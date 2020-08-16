import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';
import 'package:r2a_mobile/utils/extension.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AddPosts extends StatefulWidget {
  @override
  _AddPostsState createState() => _AddPostsState();
}

class _AddPostsState extends State<AddPosts> with WidgetsBindingObserver {
  final List<DropdownMenuItem> categoryList = [];
  var categories = {};
  final storage = new FlutterSecureStorage();
  int selectedId;
  TextEditingController textEditingController = TextEditingController();
  bool isWiritng = false;
  bool _isLoading = false;
  Map<String, String> _paths;
  Map<String, int> attachmentsId;
  File path;
  List images = List();
  List s3Urls = [];
  List attachmentKey = [];
  List attachments = [];
  List _statesList = List();
  List _districtsList = List();
  List<String> tepmPaht = [];
  var stateId;
  var district;
  bool show = false;
  final List<DropdownMenuItem> states = [];
  final List<DropdownMenuItem> districts = [];
  var config; //App config varaible
  String description;
  final _generateFormKey = GlobalKey<FormState>();
  int totalSize = 0;
  UserState userState;

  Future setCategories() async {
    var role = await storage.read(key: 'role');
    if (userState.foreignUser == 'false') {
      if (role == '1') {
        setState(() {
          categories = {1: "Social", 4: "News Feed"};
        });
      } else if (role == '2') {
        setState(() {
          categories = {2: "Medical", 4: "News Feed"};
        });
      } else {
        setState(() {
          categories = {1: "Social", 2: "Medical", 4: "News Feed"};
        });
      }
    } else {
      setState(() {
        categories = {4: "News Feed"};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setCategories().then((val) {
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        this.config = AppConfig.of(context);
      });
      getStateList();
      categories.forEach((k, v) {
        categoryList.add(DropdownMenuItem(
          child: Text(v),
          value: k,
        ));
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Future createPost() async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove Focus
    setState(() {
      _isLoading = true;
    });
    try {
      var data = {
        "description": description,
        "category": selectedId,
        "gps_data": "",
        "district": district
      };
      for (int i = 0; i < images.length; i++) {
        data["attachments[$i]attachment"] =
            await MultipartFile.fromFile(images[i]);
        data["attachments[$i]file_type"] = urlreturnId(images[i]);
      }
      FormData formData = FormData.fromMap(data);
      var bearer = await storage.read(key: 'Bearer');
      Dio dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader] = "Bearer $bearer";
      Response response = await dio
          .post(config.baseUrl + '/api/user_post_create/', data: formData);
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Post Created Successfully",
          ),
        );
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/mainpage', ModalRoute.withName('/mainpage'));
        });
      }
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Post Created Successfully",
            ),
          );
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/mainpage', ModalRoute.withName('/mainpage'));
          });
        } else if (e.response.statusCode == 400) {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Select District or Constituency",
            ),
          );
        } else if (e.response.statusCode == 413) {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "You cannot Upload More than 100 Mb",
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Something went wrong please try again",
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Something went wrong please try again",
          ),
        );
        setState(() {
          _isLoading = false;
        });
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print(e);
    }
  }

  Future getStateList() async {
    try {
      final response = await BackendService.get('/auth/states/', {}, context,
          route: '/add_posts');
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
      final response = await BackendService.get(
          '/auth/districts/$stateId', {}, context,
          route: '/add_posts');
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

  // For Images Selection Only
  void openFileExplorer() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove Focus

    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.image, allowedExtensions: null);
      if (_paths != null) {
        path = File(_paths.values.toList()[0].toString());
        for (int i = 0; i < _paths.length; i++) {
          int size = File(_paths.values.toList()[i]).lengthSync();
          totalSize = totalSize + size;
          setState(() {
            images.add(_paths.values.toList()[i]);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //For Videos Selection
  void selectVideo() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove Focus
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.video, allowedExtensions: null);

      if (_paths != null) {
        path = File(_paths.values.toList()[0].toString());
        for (int i = 0; i < _paths.length; i++) {
          int size = File(_paths.values.toList()[i]).lengthSync();
          totalSize = totalSize + size;
          setState(() {
            images.add(_paths.values.toList()[i]);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text("Add Post"),
          actions: <Widget>[
            _isLoading
                ? SizedBox.shrink()
                : FlatButton(
                    disabledTextColor:
                        Theme.of(context).textTheme.caption.color,
                    textColor: Theme.of(context).buttonColor,
                    onPressed: isWiritng
                        ? () {
                            if (_generateFormKey.currentState.validate()) {
                              if (totalSize <= 104857600) {
                                createPost();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomAlertRoundedBox(
                                    message:
                                        "You cannot Upload More than 100 Mb",
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    child: Text(
                      "Post",
                      style: TextStyle(fontSize: 20),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                  ),
          ],
        ),
        body: _isLoading
            ? Container(
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Uploading ",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        )),
                    Text(
                      "Please Wait",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ))
            : Container(
                child: Column(
                  children: <Widget>[
                    Expanded(child: addPost()),
                    mediaSelect(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget mediaSelect() {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: () {
              selectVideo();
            },
            child: Icon(
              Icons.videocam,
              size: 27,
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
          InkWell(
              onTap: () {
                openFileExplorer();
              },
              child: Icon(
                Icons.add_photo_alternate,
                size: 27,
                color: Theme.of(context).textTheme.caption.color,
              )),
        ],
      ),
    );
  }

  Widget addPost() {
    final user = Provider.of<UserState>(context);
    return SingleChildScrollView(
      child: Form(
        key: _generateFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.11,
                            width: MediaQuery.of(context).size.width * 0.11,
                            child: user.avatar == null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade400,
                                    child: Text(
                                      "${user.userName}",
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(user.avatar),
                                    backgroundColor: Colors.grey.shade400,
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Text(
                          "${user.userName}",
                          style: TextStyle(
                              color: Theme.of(context).textSelectionColor,
                              fontSize: 18),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.0,
                    MediaQuery.of(context).size.width * 0.0,
                    0,
                    0),
                child: FormField<int>(
                  validator: (value) {
                    if (selectedId == null) {
                      return "Select Category";
                    }
                    return null;
                  },
                  onSaved: (value) {},
                  builder: (
                    FormFieldState<int> state,
                  ) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InputDecorator(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(0.0),
                              labelStyle: TextStyle(
                                  color: Theme.of(context).textSelectionColor,
                                  fontSize: 20)),
                          child: Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isDense: true,
                                hint: Text(
                                  "Select Category",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                value: selectedId,
                                onChanged: (val) {
                                  state.didChange(val);
                                  if (val == 2) {
                                    setState(() {
                                      show = true;
                                    });
                                  } else {
                                    setState(() {
                                      show = false;
                                    });
                                  }
                                  setState(() => selectedId = val);
                                },
                                items: categoryList,
                              ),
                            ),
                          ),
                        ),
                        state.hasError
                            ? Text(
                                state.hasError ? state.errorText : '',
                                style: TextStyle(
                                    color: Colors.redAccent.shade700,
                                    fontSize: 12.0),
                              )
                            : SizedBox.shrink(),
                      ],
                    );
                  },
                ),
              ),
            ),
            show
                ? Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.0,
                              MediaQuery.of(context).size.width * 0.0,
                              0,
                              0),
                          child: FormField<int>(
                            validator: (value) {
                              if (stateId == null) {
                                return "Select state";
                              }
                              return null;
                            },
                            onSaved: (value) {},
                            builder: (
                              FormFieldState<int> state,
                            ) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InputDecorator(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0.0),
                                        labelStyle: TextStyle(
                                            color: Colors.white, fontSize: 20)),
                                    child: Container(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isDense: true,
                                          hint: Text(
                                            "Select State *",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textSelectionColor),
                                          ),
                                          value: stateId,
                                          items: _statesList.map((state) {
                                            return DropdownMenuItem(
                                                value: state['id'],
                                                child: Text(state['name']));
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              stateId = val;
                                              district = null;
                                            });
                                            getDistrictList(stateId);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  state.hasError
                                      ? Text(
                                          state.hasError ? state.errorText : '',
                                          style: TextStyle(
                                              color: Colors.redAccent.shade700,
                                              fontSize: 12.0),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.0,
                              MediaQuery.of(context).size.width * 0.0,
                              0,
                              0),
                          child: FormField<int>(
                            validator: (value) {
                              if (district == null) {
                                return "Select District";
                              }
                              return null;
                            },
                            onSaved: (value) {},
                            builder: (
                              FormFieldState<int> state,
                            ) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InputDecorator(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0.0),
                                        labelStyle: TextStyle(
                                            color: Colors.white, fontSize: 20)),
                                    child: Container(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isDense: true,
                                          hint: Text(
                                            "Select District *",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textSelectionColor),
                                          ),
                                          value: district,
                                          items: _districtsList.map((district) {
                                            return DropdownMenuItem(
                                                value: district['id'],
                                                child: Text(district['name']));
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              district = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  state.hasError
                                      ? Text(
                                          state.hasError ? state.errorText : '',
                                          style: TextStyle(
                                              color: Colors.redAccent.shade700,
                                              fontSize: 12.0),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: textEditingController,
              autocorrect: false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0),
                  labelStyle: TextStyle(
                      color: Theme.of(context).textSelectionColor,
                      fontSize: 20),
                  hintText: "Write something here",
                  hintStyle:
                      TextStyle(color: Theme.of(context).textSelectionColor)),
              scrollPadding: EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 100,
              onChanged: (val) {
                if (val.length > 0) {
                  setState(() {
                    description = val;
                    isWiritng = true;
                  });
                } else {
                  setState(() {
                    isWiritng = false;
                  });
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Enter Some description";
                }
                return null;
              },
              // autofocus: true,
            ),
            GridView.builder(
              primary: false,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      fileStringType(images[index]) == 'image'
                          ? Image.file(
                              File(images[index]),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                            )
                          : VideoPlayerApp(
                              file: File(images[index]),
                            ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              // BoxShadow(
                              //   color: Colors.black,
                              //   blurRadius: 6.0,
                              // )
                            ]),
                            child: CircleAvatar(
                              child: Icon(
                                Icons.clear,
                                size: 30,
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            totalSize =
                                totalSize - File(images[index]).lengthSync();
                            setState(() {
                              images.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerApp extends StatefulWidget {
  final File file;

  const VideoPlayerApp({Key key, this.file}) : super(key: key);
  @override
  _VideoPlayerAppState createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
