import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/audio_call_screen.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/services/call_methods.dart';
import 'call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();
  static dial(
      {userId,
      userName,
      userPic,
      tenantId,
      tenantName,
      tenantPic,
      context,
      isVideoCall,
      channelId}) async {
    Call call = Call(
      callerId: userId.toString(),
      callerName: userName,
      callerPic: userPic,
      receiverId: tenantId,
      receiverName: tenantName,
      receiverPic: tenantPic,
      channelId: channelId,
      isVideoCall: isVideoCall,
    );
    bool callMade = true;

    await callMethods.callLogs(call: call, status: 1).then((value) async {
      call.hasDialled = true;
      call.docId = value;
      callMade = await callMethods.makeCall(call: call);
      // await callMethods.makeCall(call: call);
    });

    // bool callMade = await callMethods.makeCall(call: call);
    call.hasDialled = true;

    if (callMade) {
      if (call.isVideoCall) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(call: call),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCallSCreen(call: call),
            ));
      }
    }
  }
}
