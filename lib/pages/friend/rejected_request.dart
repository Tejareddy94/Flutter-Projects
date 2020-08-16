import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/circle_avatar_for_list.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/friends_shimmering.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class RejectedRequest extends StatefulWidget {
  @override
  _RejectedRequestState createState() => _RejectedRequestState();
}

class _RejectedRequestState extends State<RejectedRequest> {
  final storage = new FlutterSecureStorage();
  var _users = [];
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    this.getFriendRequestList();
  }

  getFriendRequestList() {
    Future.delayed(Duration.zero, () async {
      var bearer = await storage.read(key: 'Bearer');
      try {
        final response = await BackendService.get(
            '/api/friends/rejected_list',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context, route: '/friends');

        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          setState(() {
            _users = _data["data"];
            isLoading = false;
          });
        } else if (response.statusCode == 401) {
          await storage.delete(key: 'Bearer');
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
    }
      catch (err) {
        print(err);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Column(
            children: <Widget>[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, int index) {
                  return FriendsShimmering();
                },
              ),
            ],
          )
        : _users.length == 0 ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12),
              child: FriendsShimmering(),
            ),
            Text('No rejected Friend Requests', style: TextStyle(color: Colors.white),)
          ],
        ) : Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
            child: ListView.separated(
              itemCount: _users.length,
              itemBuilder: (BuildContext ctxt, int index) {
                final user = _users[index]["from_user"];
                return ListTile(
                  leading: CircleAvatarForList(
                    firstName: user["first_name"],
                    lastName: user["last_name"],
                    avatar: user["profile"]["avatar"],
                    parentContext: context,
                    dia: 0.14,
                    fontSize: 25.0,
                  ),
                  title: Text(
                    user["first_name"] + " " + user["last_name"],
                    style: TextStyle(fontSize: 18.0),
                  ),
                  subtitle: user["constituency_details"] == null ||
                          user["constituency_details"] == ""
                      ? null
                      : Text(
                          user["constituency_details"]["constituency"],
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                        ),
                  onTap: () {
                    Navigator.pushNamed(context, '/user_profile',
                        arguments: user["id"]);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                    color: Colors.black,
                    indent: MediaQuery.of(context).size.width * 0.17);
              },
            ),
          );
  }
}
