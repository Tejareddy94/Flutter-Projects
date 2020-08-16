import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/request_admin/create_ticket.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/request_admin/ticket.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared/loader.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  final storage = new FlutterSecureStorage();
  var tickets = [];
  var isLoading = true;
  int _currentPage = 1;
  bool _isMore = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    this.getTicketList(currentPage: _currentPage);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    super.initState();
  }

  _getMoreData() {
    if (_isMore) {
      getTicketList(currentPage: _currentPage);
    }
  }

  getTicketList({int currentPage, bool isPull}) {
    Future.delayed(Duration.zero, () async {
      isLoading = true;
      try {
        var bearer = await storage.read(key: 'Bearer');
        final response = await BackendService.get(
            '/api/support/my_admin_tickets/?page=$currentPage',
            {HttpHeaders.authorizationHeader: "Bearer " + bearer},
            context,
            route: '/friends');
        if (response.statusCode == 200) {
          var _data = jsonDecode(response.body);
          if (isPull == true) {
            tickets = _data["results"];
          } else {
            tickets += _data["results"];
          }
          if (_data['next'] != null) {
            setState(() {
              _isMore = true;
              _currentPage++;
            });
          } else {
            _isMore = false;
          }
          setState(() {
            isLoading = false;
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
        } else {
          setState(() => isLoading = false);
          refreshList();
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

  Future<Null> refreshList() async {
    tickets = [];
    _isMore = false;
    _currentPage = 1;
    getTicketList(currentPage: _currentPage, isPull: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tickets")),
      body: isLoading == true
          ? Loading()
          : tickets.length == 0
              ? RefreshIndicator(
                  onRefresh: refreshList,
                  backgroundColor: Theme.of(context).backgroundColor,
                  color: Theme.of(context).primaryColor,
                  notificationPredicate: defaultScrollNotificationPredicate,
                  child: Center(
                    child: Text(
                      'No Tickets',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: refreshList,
                  backgroundColor: Theme.of(context).backgroundColor,
                  color: Theme.of(context).primaryColor,
                  notificationPredicate: defaultScrollNotificationPredicate,
                  child: Container(
                    child: ListView.separated(
                      itemCount: tickets.length + 1,
                      controller: _scrollController,
                      itemBuilder: (BuildContext ctxt, int index) {
                        if (index == tickets.length) {
                          if (_isMore == true) {
                            return Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else if (tickets.length == 0) {
                          return Container();
                        } else {
                          return ListTile(
                            title: Text(
                              tickets[index]["title"],
                              style: TextStyle(fontSize: 16.0),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return Ticket(
                                      title: tickets[index]["title"],
                                      description: tickets[index]
                                          ["description"],
                                      id: tickets[index]["id"],
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: MediaQuery.of(context).size.height * 0.002,
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return CreateTicket();
              },
            ),
          );
        },
        tooltip: 'Add Ticket',
        child: FaIcon(
          FontAwesomeIcons.plus,
          size: 20,
        ),
        elevation: 10.0,
      ),
    );
  }
}
