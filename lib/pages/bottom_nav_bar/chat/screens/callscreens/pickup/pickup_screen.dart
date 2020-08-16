import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/audio_call_screen.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/services/call_methods.dart';
import '../call_screen.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  final CollectionReference callLogsCollection =
      Firestore.instance.collection("callLogs");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          // alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                "Incoming...",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                widget.call.callerName,
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.call.callerPic),
                radius: MediaQuery.of(context).size.width * 0.23,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  RawMaterialButton(
                    onPressed: () async => await requestPermission(
                            [Permission.camera, Permission.microphone])
                        ? widget.call.isVideoCall
                            ? pushToVideoCall(context)
                            : pushToAudioCall(context)
                        : {},
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.green,
                    padding: const EdgeInsets.all(15.0),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.call,
                  //     size: MediaQuery.of(context).size.width * 0.1,
                  //   ),
                  //   color: Colors.green,
                  //   onPressed: () async => await requestPermission(
                  //           [Permission.camera, Permission.microphone])
                  //       ? widget.call.isVideoCall
                  //           ? pushToVideoCall(context)
                  //           : pushToAudioCall(context)
                  //       : {},
                  // ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  // SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                  RawMaterialButton(
                    onPressed: () async {
                      FlutterRingtonePlayer.stop();
                      await callMethods.endCall(call: widget.call, status: 1);
                    },
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.redAccent,
                    padding: const EdgeInsets.all(15.0),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.call_end,
                  //     size: MediaQuery.of(context).size.width * 0.1,
                  //   ),
                  //   color: Colors.redAccent,
                  //   onPressed: () async {
                  //     FlutterRingtonePlayer.stop();
                  //     await callMethods.endCall(call: widget.call, status: 1);
                  //   },
                  // ),
                  Spacer(),
                ],
              ),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pushToVideoCall(BuildContext context) {
    callLifted();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(call: widget.call),
      ),
    );
  }

  void pushToAudioCall(BuildContext context) {
    callLifted();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                AudioCallSCreen(call: widget.call)));
  }

  Future<bool> requestPermission(List<Permission> permission) async {
    Map<Permission, PermissionStatus> status = await permission.request();
    if (await Permission.camera.isDenied &&
        await Permission.microphone.isDenied) {
      return false;
    } else
      return true;
  }

  Future callLifted() async {
    await callLogsCollection
        .document(widget.call.docId)
        .updateData({"call_status": 2});
  }
}
