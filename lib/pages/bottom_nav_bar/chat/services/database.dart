import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  updateGroupTimeStamp(groupId, lastMessage,type) async {
    Firestore.instance.collection("chatRoom").document(groupId).updateData({
      "timestamp": DateTime.now().toUtc(),
      "last_message": lastMessage,
      "type" : type
    }).catchError((e) {
      print(e);
    });
  }

  getUserById(String id) async {
    return Firestore.instance.collection("users").document(id).get();
  }

  Stream<DocumentSnapshot> getUserStatusId(String id)  {
    return Firestore.instance.collection("users").document(id).snapshots();
  }


  addUser(userData, id) {
    Firestore.instance
        .collection("users")
        .document(id)
        .setData(userData)
        .catchError((e) {
      print(e);
    });
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('name', isEqualTo: searchField)
        .snapshots();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("message")
        .where('groupId', isEqualTo: chatRoomId).limit(50)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("message")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String itIsMyName) async {
    return await Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
