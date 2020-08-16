import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';
import 'package:r2a_mobile/utils/emoji_decode.dart';
import 'package:r2a_mobile/utils/extension.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditPosts extends StatefulWidget {
  final PostModel post;

  const EditPosts({Key key, this.post}) : super(key: key);

  @override
  _EditPostsState createState() => _EditPostsState();
}

class _EditPostsState extends State<EditPosts> {
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
  List deleteAttachment = [];
  var config; //App config varaible
  String description;
  List postAttachments = List();
  bool toUPloadAttachemnts;
  List _statesList = List();
  List _districtsList = List();
  var stateId;
  var district;
  bool show = false;
  int totalSize = 0;
  final List<DropdownMenuItem> states = [];
  final List<DropdownMenuItem> districts = [];
  final List<DropdownMenuItem> constituencies = [];
  final _generateFormKey = GlobalKey<FormState>();
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
    print(categoryList);
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.config = AppConfig.of(context);
    });
    setCategories().then((val) {
      setStateList();
      textEditingController.text = stringToEmoji(widget.post.description);
      setState(() {
        postAttachments = widget.post.attachments;
        selectedId = widget.post.category;
      });
      categories.forEach((k, v) {
        categoryList.add(DropdownMenuItem(
          child: Text(v),
          value: k,
        ));
      });
    });
    super.initState();
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

  Future setStateList() async {
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

        if (widget.post.category == 2) {
          show = true;
          for (int i = 0; i < _statesList.length; i++) {
            if (_statesList[i]['name'] == widget.post.districtDetails.state) {
              stateId = _statesList[i]["id"];
              setDistrictList(stateId);
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future setDistrictList(int stateId) async {
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
        if (widget.post.category == 2) {
          for (int i = 0; i < _districtsList.length; i++) {
            if (_districtsList[i]['name'] ==
                widget.post.districtDetails.district) {
              district = _districtsList[i]["id"];
            }
          }
        }
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

  Future delteAttachments() async {
    setState(() {
      _isLoading = true;
    });
    for (int attachment in deleteAttachment) {
      try {
        var bearer = await storage.read(key: 'Bearer');
        final response = await BackendService.delete(
            '/api/delete_users_attachment/$attachment/',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context);
        if (response.statusCode == 200) {
          setState(() {
            toUPloadAttachemnts = true;
          });
        } else {
          toUPloadAttachemnts = false;
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Something went wrong try again later",
            ),
          );
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
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "something went wrong on our end",
          ),
        );
        print(e);
      }
    }
    if (toUPloadAttachemnts == true) {
      if (images.length > 0) {
        updatePost();
      } else {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Post Update Successful",
          ),
        );
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/mainpage', ModalRoute.withName('/mainpage'));
        });
      }
    }
  }

  Future updatePost() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).requestFocus(new FocusNode()); //remove Focus
    try {
      var data = {
        "description": textEditingController.text,
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
      dio
          .put(config.baseUrl + '/api/user_post/${widget.post.id}/',
              data: formData)
          .then((res) {
        if (res.statusCode == 200) {
          showDialog(
            context: context,
            builder: (_) => CustomAlertRoundedBox(
              message: "Post Update Successful",
            ),
          );
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/mainpage', ModalRoute.withName('/mainpage'));
          });
        } else if (res.statusCode == 413) {
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
      }).catchError((err) {
        print(err);
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Something went wrong try again later",
          ),
        );
      });
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
      attachments = [];
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (_) => CustomAlertRoundedBox(
          message: "something went wrong on our end",
        ),
      );
      print(e);
    }
  }

  void openFileExplorer() async {
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.image, allowedExtensions: null);
      path = File(_paths.values.toList()[0].toString());
      for (int i = 0; i < _paths.length; i++) {
        int size = File(_paths.values.toList()[i]).lengthSync();
        totalSize = totalSize + size;
        setState(() {
          images.add(_paths.values.toList()[i]);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void selectVideo() async {
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.video, allowedExtensions: null);
      path = File(_paths.values.toList()[0].toString());
      for (int i = 0; i < _paths.length; i++) {
        int size = File(_paths.values.toList()[i]).lengthSync();
        totalSize = totalSize + size;
        setState(() {
          images.add(_paths.values.toList()[i]);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Post"),
        actions: <Widget>[
          _isLoading
              ? SizedBox.shrink()
              : FlatButton(
                  disabledTextColor: Colors.white54,
                  textColor: Colors.orange[400],
                  onPressed: () {
                    if (deleteAttachment.length > 0) {
                      delteAttachments();
                    } else {
                      toUPloadAttachemnts = true;
                    }
                    if (toUPloadAttachemnts == true) {
                      if (totalSize <= 104857600) {
                        updatePost();
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => CustomAlertRoundedBox(
                            message: "You cannot Upload More than 100 Mb",
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 20, color: Colors.orange[400]),
                  ),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
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
                      child: CircularProgressIndicator()),
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
              color: Color(0xFFbabbbf),
            ),
          ),
          InkWell(
              onTap: () {
                openFileExplorer();
              },
              child: Icon(
                Icons.add_photo_alternate,
                size: 27,
                color: Color(0xFFbabbbf),
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
                                      user.userName,
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                child: FormField<int>(
                  validator: (value) {
                    if (value == null) {
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
                              labelStyle:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          child: Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isDense: true,
                                hint: Text(
                                  "Select Category",
                                  style: TextStyle(color: Colors.white70),
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
                        padding: const EdgeInsets.all(8.0),
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
                                                color: Colors.white70),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
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
                                                color: Colors.white70),
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
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                  hintText: "Enter Description here",
                  hintStyle: TextStyle(color: Colors.white)),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            widget.post.attachments.length != 0
                ? GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: postAttachments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            postAttachments[index]['file_type'] == 1
                                ? Stack(
                                    children: <Widget>[
                                      Center(
                                          child: CircularProgressIndicator()),
                                      Center(
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/output-onlinepngtools.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          image: postAttachments[index]
                                              ['attachment'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  )
                                : VideoPlayerApp(
                                    url: postAttachments[index]['attachment'],
                                  ),
                            Positioned(
                              right: 5,
                              top: 5,
                              child: InkWell(
                                child: Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 6.0,
                                    )
                                  ]),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 30,
                                    color: Colors.white60,
                                  ),
                                ),
                                onTap: () {
                                  deleteAttachment
                                      .add(postAttachments[index]['id']);
                                  setState(() {
                                    // images.replaceRange(index, index + 1, ['Add Image']);
                                    postAttachments.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
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
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      fileStringType(images[index]) == 'image'
                          ? Image.file(File(images[index]),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width)
                          : VideoPlayerApp(
                              file: File(images[index]),
                            ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          child: Icon(
                            Icons.remove_circle,
                            size: 25,
                            color: Colors.red,
                          ),
                          onTap: () {
                            setState(() {
                              // images.replaceRange(index, index + 1, ['Add Image']);
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
  final String url;

  const VideoPlayerApp({Key key, this.file, this.url}) : super(key: key);
  @override
  _VideoPlayerAppState createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file);
    } else {
      _controller = VideoPlayerController.network(widget.url);
    }

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    // _controller.play();
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
        aspectRatio: 4 / 3,
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
