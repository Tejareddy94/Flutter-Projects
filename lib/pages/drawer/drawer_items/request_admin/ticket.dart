import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/request_admin/tickets.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'dart:io';

import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class Ticket extends StatefulWidget {
  Ticket({Key key, this.title, this.description, this.id}) : super(key: key);
  final title;
  final description;
  final id;

  @override
  _TicketState createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final storage = new FlutterSecureStorage();
  bool isLoading = true;
  var ticketDetails = {};

  @override
  void initState() {
    super.initState();
    getTicketDetails();
  }

  getTicketDetails() {
    Future.delayed(Duration.zero, () async {
      isLoading = true;
      try {
        var bearer = await storage.read(key: 'Bearer');
        final response = await BackendService.get(
            '/api/support/get_admin_ticket/${widget.id}',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context,
            route: '/friends');
        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          setState(() {
            isLoading = false;
            ticketDetails = _data["data"];
          });
        } else if (response.statusCode == 401) {
          await storage.deleteAll();
          UserState userState = Provider.of<UserState>(context, listen: true);
          userState.setUserDetails(
              name: "",
              email: "",
              bearer: "",
              canCreate: "",
              phoneNumber: "",
              role: "",
              avatar: "");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
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
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Something went wrong",
          ),
        );
      }
    });
  }

  deleteTicket() async {
    int id = widget.id;
    try {
      var bearer = await storage.read(key: 'Bearer');
      final response = await BackendService.delete(
          '/api/support/delete_admin_ticket/$id/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer},
          context);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Tickets();
            },
          ),
        );
      } else {
        print("error status code ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heigth = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Ticket")),
      body: isLoading ? Loading() : Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Card(
              color: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: heigth * 0.018),
              elevation: 2,
              child: ClipPath(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        dense: false,
                        title: Text(
                          ticketDetails["title"],
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                        ),
                        subtitle:
                            Text(ticketDetails["created_at"].substring(0, 10)),
                        trailing: ticketDetails["status"]
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
                      ),
                      Divider(
                        height: heigth * 0.005,
                        thickness: 2,
                      ),
                      Container(
                        height: heigth * 0.5,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04, vertical: heigth * 0.02),
                        child: Text(
                          ticketDetails["description"],
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          deleteTicket();
        },
        tooltip: 'Delete',
        label: Text(' Delete '),
        elevation: 10.0,
        backgroundColor: Colors.red,
      ),
    );
  }
}
