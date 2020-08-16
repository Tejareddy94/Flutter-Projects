import 'dart:convert';

class NotificationAndroid {
  Notification notification;
  Data data;

  NotificationAndroid({this.notification, this.data});

  NotificationAndroid.fromJson(dynamic json) {
    notification = json['notification'] != null
        ? new Notification.fromJson(json['notification'])
        : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notification != null) {
      data['notification'] = this.notification.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Notification {
  String title;
  String body;

  Notification({this.title, this.body});

  Notification.fromJson(dynamic json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

class Data {
  Chat chat;

  Data({this.chat});

  Data.fromJson(dynamic json) {
    chat = json['chat'] != null ? new Chat.fromJson(jsonDecode(json['chat'])) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.chat != null) {
      data['chat'] = this.chat.toJson();
    }
    return data;
  }
}

class Chat {
  String userId;
  String chatRoomId;
  String recevierId;

  Chat({this.userId, this.chatRoomId, this.recevierId});

  Chat.fromJson(dynamic json) {
    userId = json['user_id'];
    chatRoomId = json['chat_room_id'];
    recevierId = json['recevier_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['chat_room_id'] = this.chatRoomId;
    data['recevier_id'] = this.recevierId;
    return data;
  }
}
