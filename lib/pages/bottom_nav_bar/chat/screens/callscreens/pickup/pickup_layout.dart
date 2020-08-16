import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_screen.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/services/call_methods.dart';
import 'package:r2a_mobile/shared_state/call_ringtone_state.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final userId;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final UserState userProvider = Provider.of<UserState>(context);
    final CallRingToneState callRingToneState = Provider.of<CallRingToneState>(context);
    return
        // (userProvider != null && userId != null)
        //     ?
        StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callListening(uid: userId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data != null) {
          Call call = Call.fromMap(snapshot.data.data);
          if (!call.hasDialled) {
            callRingToneState.playRingTone();
            return PickupScreen(call: call);
          } else {
            print("call dailed");
          }
        }
        FlutterRingtonePlayer.stop();
        return scaffold;
      },
    );
    // :
    //  Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(
    //         backgroundColor: Colors.red,
    //       ),
    //     ),
    //   );
  }
}
