import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/request_admin/tickets.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class CreateTicket extends StatefulWidget {
  @override
  _CreateTicketState createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  final storage = new FlutterSecureStorage();

  String description = "";
  String title = "";

  addTicket(context) async {
    var bearer = await storage.read(key: 'Bearer');
    try {
      var data = {"title": title, "description": description};
      final response = await BackendService.post('/api/support/create_ticket/',
          {HttpHeaders.authorizationHeader: "Bearer " + bearer}, data, context);
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Create Ticket")),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
          vertical: MediaQuery.of(context).size.height * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: titleController,
              onChanged: (val) {
                if (val.length > 0) {
                  setState(() {
                    title = val;
                  });
                }
              },
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter Title",
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextFormField(
              controller: descriptionController,
              autocorrect: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(20.0),
                labelStyle:
                    TextStyle(color: Colors.grey, fontSize: 20),
                hintText: "Enter Some description",
                hintStyle: TextStyle(color: Colors.grey),
              ),
              scrollPadding: EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              minLines: 8,
              maxLines: 20,
              onChanged: (val) {
                if (val.length > 0) {
                  setState(() {
                    description = val;
                  });
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Enter Some description";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addTicket(context);
        },
        tooltip: 'Save',
        label: Text('  Save  '),
        elevation: 10.0,
      ),
    );
  }
}
