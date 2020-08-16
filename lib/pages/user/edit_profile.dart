import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter/material.dart';
import 'package:r2a_mobile/shared/custom_circle_avatar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:dio/dio.dart';
import 'package:r2a_mobile/env/app_config.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key key, this.userDetails});
  final userDetails;
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var userDetails = {};
  String firstName = '';
  String lastname = '';
  String dob;
  int sex;
  bool anonymous;
  int profileGroup;
  String phoneNumber;
  String email;
  String avatarUrl;
  final editFormKey = GlobalKey<FormState>();
  var value;
  final storage = new FlutterSecureStorage();
  bool loading = false;
  var config;

  String _path;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void populateData() {
    setState(() {
      userDetails = widget.userDetails;
      firstName = userDetails['first_name'];
      lastname = userDetails['last_name'];
      sex = userDetails['profile']['sex'];
      anonymous = userDetails['anonymous'];
      phoneNumber = userDetails['phone_number'];
      email = userDetails['email'];
      avatarUrl = userDetails["profile"]["avatar"];
      profileGroup = anonymous == true ? 1 : 2;
      dob = userDetails['profile']['dob'];
    });
  }

  void writeToStorage(data) async {
    await storage.write(
        key: "avatar", value: data["data"]["profile"]["avatar"]);
    var name = data["data"]["first_name"] + " " + data["data"]["last_name"];
    await storage.write(key: "name", value: name);
  }

  void updateProfileData() async {
    var bearer = await storage.read(key: 'Bearer');
    Map<String, dynamic> data = {
      "first_name": firstName,
      "last_name": lastname,
      "profile.sex": sex,
      "profile.dob": dob,
      "anonymous": anonymous
    };
    if (_path != null) {
      data["profile.avatar"] = await MultipartFile.fromFile(_path);
    }
    FormData formData = FormData.fromMap(data);

    // #TODO: investigate and Move to backeend services
    Dio dio = new Dio();
    dio.options.headers[HttpHeaders.authorizationHeader] = "Bearer $bearer";
    dio.put(config.baseUrl + '/api/myprofile/', data: formData).then((res) {
      if (res.statusCode == 200) {
        writeToStorage(res.data);
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(
            'Some thing went wrong please try again',
            style: TextStyle(color: Colors.redAccent),
          ),
          backgroundColor: Color(0xff303136),
        ));
      }
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
          'Some thing went wrong please try again',
          style: TextStyle(color: Colors.redAccent),
        ),
        backgroundColor: Color(0xff303136),
      ));
    });
  }

  void saveData() async {
    setState(() {
      loading = true;
    });
    updateProfileData();
  }

  void openFileExplorer() async {
    try {
      var data = await FilePicker.getFilePath(type: FileType.image);
      setState(() {
        _path = data;
      });
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text(
            'Some thing went wrong please try again',
            style: TextStyle(color: Colors.redAccent),
          ),
          backgroundColor: Color(0xff303136),
        ),
      );
    }
  }

  void setProfileStatus(int e) {
    setState(() {
      if (e == 1) {
        profileGroup = 1;
        anonymous = true;
      } else {
        profileGroup = 2;
        anonymous = false;
      }
    });
  }

  void setSex(int e) {
    setState(() {
      if (e == 1) {
        sex = 1;
      } else if (e == 2) {
        sex = 2;
      } else {
        sex = 3;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    populateData();
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    DateTime newDate = DateTime(date.year - 20, date.month, date.day);
    TextEditingController firstNameController = new TextEditingController();
    firstNameController.text = firstName;
    firstNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: firstNameController.text.length));

    TextEditingController lastNameController = new TextEditingController();
    lastNameController.text = lastname;
    lastNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: lastNameController.text.length));

    config = AppConfig.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: loading
          ? Loading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.16,
                  width: MediaQuery.of(context).size.width * 1,
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Center(
                        child: avatarUrl == ""
                            ? CustomCircleAvatar(
                                firstName: firstName,
                                lastName: lastname,
                                parentContext: context,
                              )
                            : ClipOval(
                                child: Container(
                                  child: _path == null
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(File(_path),
                                          fit: BoxFit.cover),
                                  width:
                                      MediaQuery.of(context).size.width * 0.16,
                                  height:
                                      MediaQuery.of(context).size.width * 0.16,
                                ),
                              ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      InkWell(
                          onTap: () {
                            openFileExplorer();
                          },
                          child: Text('Change Photo',
                              style: Theme.of(context).textTheme.headline2))
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Form(
                  key: editFormKey,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          enabled: false,
                          controller: TextEditingController(text: phoneNumber),
                          style: Theme.of(context).textTheme.subtitle1,
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelStyle: TextStyle(color: Colors.grey),
                              labelText: 'Phone Number',
                              focusColor: Colors.grey),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        TextFormField(
                          enabled: false,
                          controller: TextEditingController(text: email),
                          style: Theme.of(context).textTheme.subtitle1,
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelStyle: TextStyle(color: Colors.grey),
                              labelText: 'Email',
                              focusColor: Colors.grey),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: firstNameController,
                                style: Theme.of(context).textTheme.subtitle1,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    labelText: 'First Name',
                                    focusColor: Colors.grey),
                                onChanged: (value) {
                                  setState(() {
                                    firstName = value;
                                  });
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'First Name cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: lastNameController,
                                style: Theme.of(context).textTheme.subtitle1,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    labelStyle:
                                        TextStyle(color: Color(0xffa9aaae)),
                                    labelText: 'Last Name',
                                    focusColor: Color(0xffa9aaae)),
                                onChanged: (value) {
                                  setState(() {
                                    lastname = value;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime newDateTime = await showRoundedDatePicker(
                              context: context,
                              initialDate: newDate,
                              firstDate: DateTime(1950),
                              lastDate: newDate,
                              theme: ThemeData.dark(),
                            );
                            if (newDateTime != null) {
                              setState(() {
                                dob = DateFormat('yyyy-MM-dd')
                                    .format(newDateTime);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              enabled: false,
                              controller: TextEditingController(text: dob),
                              style: Theme.of(context).textTheme.subtitle1,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                labelStyle: TextStyle(color: Color(0xffa9aaae)),
                                labelText: 'Date of Birth',
                                focusColor: Color(0xffa9aaae),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gender',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              value: 1,
                              onChanged: (int val) {
                                setSex(val);
                              },
                              groupValue: sex,
                              activeColor: Colors.white,
                            ),
                            Text(
                              'Male',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.grey),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Radio(
                              value: 2,
                              onChanged: (val) {
                                setSex(val);
                              },
                              groupValue: sex,
                              activeColor: Colors.white,
                            ),
                            Text(
                              'Female',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.grey),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Radio(
                              value: 3,
                              onChanged: (val) {
                                setSex(val);
                              },
                              groupValue: sex,
                              activeColor: Colors.white,
                            ),
                            Text(
                              'private',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.grey),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Profile',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              value: 1,
                              onChanged: (int val) {
                                setProfileStatus(val);
                              },
                              groupValue: profileGroup,
                              activeColor: Colors.white,
                            ),
                            Text(
                              'Anonymous',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.grey),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Radio(
                              value: 2,
                              onChanged: (int val) {
                                setProfileStatus(val);
                              },
                              groupValue: profileGroup,
                              activeColor: Colors.white,
                            ),
                            Text(
                              'Public',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: Theme.of(context).appBarTheme.textTheme,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
            textColor: Theme.of(context).buttonColor,
            onPressed: () {
              if (editFormKey.currentState.validate()) {
                editFormKey.currentState.save();
                saveData();
              }
            },
            child: Text("Save", style: TextStyle(fontSize: 20)),
          )
        ],
      ),
    );
  }
}
