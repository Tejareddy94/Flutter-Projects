import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call_logs.dart';

class CallMethods {
  final CollectionReference callCollection =
      Firestore.instance.collection("calls");

  final CollectionReference callLogsCollection =
      Firestore.instance.collection("callLogs");

  Stream<QuerySnapshot> callStream({String uid}) => callCollection.snapshots();

  Stream<DocumentSnapshot> callListening({String uid}) {
    return callCollection.document(uid).snapshots();
  }

  Future<bool> makeCall({Call call}) async {
    try {
      // Firestore.instance.collection("calls");
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);
      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);
      await callCollection.document(call.callerId).setData(hasDialledMap);
      await callCollection.document(call.receiverId).setData(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future callLogs({Call call, int status}) async {
    CallLog callLog = CallLog(
        callerId: call.callerId,
        callerName: call.callerName,
        callerPic: call.callerPic,
        isVideoCall: call.isVideoCall,
        receiverId: call.receiverId,
        receiverName: call.receiverName,
        receiverPic: call.receiverPic,
        channelId: call.channelId,
        hasDialled: call.hasDialled,
        callStatus: status,
        timestamp: Timestamp.now());
    Map<String, dynamic> callLogMap = callLog.toMap(callLog);
    callLogMap.addAll({
      "users": [call.callerId, call.receiverId]
    });
    Map<String, dynamic> callField = {call.callerId: callLogMap};
    DocumentReference docId = await callLogsCollection.add(callLogMap);
    return docId.documentID;
  }

  Future<bool> endCall({Call call, int status}) async {
    try {
      if (status == 2) {
        await callLogsCollection
            .document(call.docId)
            .updateData({"call_status": 2});
      }
      await callCollection.document(call.callerId).delete();
      await callCollection.document(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
