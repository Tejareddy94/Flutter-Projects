import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/request_admin/tickets.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  final storage = new FlutterSecureStorage();
  var userDetails;
  final sex = ["", "Male", "Female", "Private"];
  var avatar = "";
  var email = "";
  var phoneNumber = "";
  var fullName = "";
  var bearer;
  var foreignUser = "";
  var id;
  UserState userState;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() {
    Future.delayed(Duration.zero, () async {
      bearer = await storage.read(key: 'Bearer');
      try {
        final response = await BackendService.get('/api/myprofile',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer}, context,
            route: "/profile");

        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          setState(() {
            userDetails = _data["data"];
            avatar = userDetails["profile"]["avatar"];
            email = userDetails["email"];
            phoneNumber = userDetails["phone_number"];
            fullName =
                '${userDetails["first_name"]} ${userDetails["last_name"]}';
            isLoading = false;
            foreignUser = userDetails['foreign_user'] ? 'true' : 'false';
            id = userDetails['id'].toString();
          });
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
              role: "",
              foreignUser: "");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        } else {
          print('Something went wrong!');
          setState(() => isLoading = true);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    userState = Provider.of<UserState>(context, listen: true);
    userState.setUserDetails(
        id: id,
        name: fullName,
        email: email,
        bearer: userState.bearer,
        canCreate: userState.canCreate,
        phoneNumber: userState.phoneNumber,
        role: userState.role,
        avatar: avatar,
        foreignUser: foreignUser);
    final heigth = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.9),
        body: isLoading
            ? Loading()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    stretch: true,
                    // backgroundColor: Color(0xFF303136),
                    expandedHeight: heigth * 0.3,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      stretchModes: [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle,
                        // StretchMode.blurBackground
                      ],
                      title: Text(
                        userState.userName,
                        style: TextStyle(
                          // color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      background: Image.network(
                        userState.avatar,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: Card(
                            color: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: EdgeInsets.only(
                                left: width * 0.05,
                                right: width * 0.05,
                                top: heigth * 0.018,
                                bottom: heigth * 0.00),
                            elevation: 2,
                            child: ClipPath(
                              child: Container(
                                // decoration: BoxDecoration(
                                //   border: Border(
                                //     right: BorderSide(
                                //         color: Color(0xFF7289D9),
                                //         width: width * 0.01),
                                //   ),
                                // ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      dense: true,
                                      // contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                                      leading: Container(
                                        padding:
                                            EdgeInsets.only(top: heigth * 0.01),
                                        child: Icon(
                                          Icons.phone,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Phone',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                        ),
                                      ),
                                      subtitle: Text(
                                        userState.phoneNumber,
                                      ),
                                    ),
                                    Divider(
                                      indent: width * 0.17,
                                      endIndent: width * 0.08,
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding:
                                            EdgeInsets.only(top: heigth * 0.0),
                                        child: Icon(
                                          Icons.email,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Email',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${userState.email}",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Card(
                            color: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: EdgeInsets.only(
                                left: width * 0.05,
                                right: width * 0.05,
                                top: heigth * 0.018,
                                bottom: heigth * 0.00),
                            elevation: 2,
                            child: ClipPath(
                              child: Container(
                                // decoration: BoxDecoration(
                                //   border: Border(
                                //     right: BorderSide(
                                //         color: Color(0xFF7289D9),
                                //         width: width * 0.01),
                                //   ),
                                // ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding:
                                            EdgeInsets.only(top: heigth * 0.01),
                                        child: Icon(
                                          Icons.person_outline,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Gender',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                        ),
                                      ),
                                      subtitle: Text(
                                        sex[userDetails["profile"]["sex"]],
                                      ),
                                    ),
                                    Divider(
                                      indent: width * 0.17,
                                      endIndent: width * 0.08,
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding:
                                            EdgeInsets.only(top: heigth * 0.0),
                                        child: Icon(
                                          Icons.date_range,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Date Of Birth',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                        ),
                                      ),
                                      subtitle: Text(
                                        userDetails["profile"]["dob"],
                                      ),
                                    ),
                                    // Divider(
                                    //   color: Colors.white30,
                                    //   indent: width * 0.17,
                                    //   endIndent: width * 0.08,
                                    // ),
                                    // ListTile(
                                    //   dense: true,
                                    //   leading: Container(
                                    //     padding:
                                    //         EdgeInsets.only(top: heigth * 0.01),
                                    //     child: Icon(
                                    //       Icons.calendar_today,
                                    //       color: Colors.white60,
                                    //     ),
                                    //   ),
                                    //   title: Text(
                                    //     'Age',
                                    //     style: TextStyle(
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    //   subtitle: Text(
                                    //     userDetails["age"].toString(),
                                    //     style: TextStyle(
                                    //         color: Colors.white70,
                                    //         fontStyle: FontStyle.italic),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        userDetails["constituency_details"] == null
                            ? Container()
                            : Container(
                                child: Card(
                                  color: Theme.of(context).backgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      right: width * 0.05,
                                      top: heigth * 0.018,
                                      bottom: heigth * 0.00),
                                  elevation: 2,
                                  child: ClipPath(
                                    child: Container(
                                      // height: 300,
                                      // decoration: BoxDecoration(
                                      //   border: Border(
                                      //     right: BorderSide(
                                      //         color: Color(0xFF7289D9),
                                      //         width: width * 0.01),
                                      //   ),
                                      // ),
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            dense: true,
                                            leading: Container(
                                              padding: EdgeInsets.only(
                                                  top: heigth * 0.01),
                                              child: Icon(
                                                Icons.my_location,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                            ),
                                            title: Text(
                                              'Constituency',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                              ),
                                            ),
                                            subtitle: Text(
                                              userDetails[
                                                      "constituency_details"]
                                                  ["constituency"],
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                          Divider(
                                            indent: width * 0.17,
                                            endIndent: width * 0.08,
                                          ),
                                          ListTile(
                                            dense: true,
                                            leading: Container(
                                              padding: EdgeInsets.only(
                                                  top: heigth * 0.01),
                                              child: Icon(
                                                Icons.place,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                            ),
                                            title: Text(
                                              'District',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                              ),
                                            ),
                                            subtitle: Text(
                                              userDetails[
                                                      "constituency_details"]
                                                  ["district"],
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                          Divider(
                                            indent: width * 0.17,
                                            endIndent: width * 0.08,
                                          ),
                                          ListTile(
                                            dense: true,
                                            leading: Container(
                                              padding: EdgeInsets.only(
                                                  top: heigth * 0.01),
                                              child: Icon(
                                                Icons.place,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                            ),
                                            title: Text(
                                              'State',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                              ),
                                            ),
                                            subtitle: Text(
                                              userDetails[
                                                      "constituency_details"]
                                                  ["state"],
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Container(
                          child: Card(
                            color: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: EdgeInsets.only(
                                left: width * 0.05,
                                right: width * 0.05,
                                top: heigth * 0.018,
                                bottom: heigth * 0.00),
                            elevation: 2,
                            child: ClipPath(
                              child: Container(
                                // height: 300,
                                // decoration: BoxDecoration(
                                //   border: Border(
                                //     right: BorderSide(
                                //         color: Color(0xFF7289D9),
                                //         width: width * 0.01),
                                //   ),
                                // ),
                                child: Column(
                                  children: <Widget>[
                                    Visibility(
                                      visible: userState.role == '3',
                                      child: ListTile(
                                        dense: true,
                                        leading: Container(
                                          padding: EdgeInsets.only(
                                              top: heigth * 0.01),
                                          child: Icon(
                                            Icons.edit,
                                            size: 25.0,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                        ),
                                        title: Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .color,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/edit_profile',
                                              arguments: userDetails);
                                        },
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    ),
                                    // Visibility(
                                    //   visible: userState.role == '3',
                                    //   child: Divider(
                                    //     indent: width * 0.17,
                                    //     endIndent: width * 0.08,
                                    //   ),
                                    // ),
                                    ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding:
                                            EdgeInsets.only(top: heigth * 0.01),
                                        child: Icon(
                                          Icons.remove_from_queue,
                                          size: 25.0,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Request Admin',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .title
                                              .color,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) {
                                              return Tickets();
                                            },
                                          ),
                                        );
                                      },
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Card(
                            color: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: heigth * 0.018),
                            elevation: 2,
                            child: ClipPath(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      dense: true,
                                      leading: Container(
                                        child: Icon(
                                          Icons.lock,
                                          size: 25.0,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                      title: Text(
                                        'Change Password',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/change_password',
                                            arguments: bearer);
                                      },
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
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
  }
}
