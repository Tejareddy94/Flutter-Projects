import 'package:cloud_firestore/cloud_firestore.dart';

class CallLog {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;
  bool isVideoCall;
  int callStatus;
  Timestamp timestamp;

  CallLog({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
    this.isVideoCall,
    this.callStatus,
    this.timestamp,
  });

  // to map
  Map<String, dynamic> toMap(CallLog callLog) {
    Map<String, dynamic> callMap = Map();
    callMap["caller_id"] = callLog.callerId;
    callMap["caller_name"] = callLog.callerName;
    callMap["caller_pic"] = callLog.callerPic;
    callMap["receiver_id"] = callLog.receiverId;
    callMap["receiver_name"] = callLog.receiverName;
    callMap["receiver_pic"] = callLog.receiverPic;
    callMap["channel_id"] = callLog.channelId;
    callMap["has_dialled"] = callLog.hasDialled;
    callMap["is_video_call"] = callLog.isVideoCall;
    callMap["call_status"] = callLog.callStatus;
    callMap["timestamp"] = callLog.timestamp;

    return callMap;
  }

  CallLog.fromMap(Map callMap) {
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerPic = callMap["caller_pic"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
    this.isVideoCall = callMap["is_video_call"];
    this.callStatus = callMap["call_status"];
    this.timestamp = callMap["timestamp"];
  }
}
