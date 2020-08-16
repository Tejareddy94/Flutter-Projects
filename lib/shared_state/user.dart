import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/Models/friends_model.dart';
import 'package:r2a_mobile/pages/Models/post_model.dart';
import 'package:r2a_mobile/pages/friend/friend_request_model.dart';
import 'package:r2a_mobile/shared/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserState with ChangeNotifier {
  ///user
  String _name = "";
  String _bearer = "";
  String _email = "";
  String _phoneNumber = "";
  String _id = "";
  String _avatar = "";
  String _role = "";
  String _canCreate = "";
  String _pushToken = "";
  String _reciverToken = "";
  String _foreignUser = "";

  setUserDetails(
      {String name,
      String bearer,
      String phoneNumber,
      String id,
      String avatar,
      String email,
      String role,
      String canCreate,
      String foreignUser}) {
    _name = name;
    _bearer = bearer;
    _email = email;
    _phoneNumber = phoneNumber;
    _id = id;
    _avatar = avatar;
    _role = role;
    _canCreate = canCreate;
    _foreignUser = foreignUser;
  }

  String get userName => _name;
  String get bearer => _bearer;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get id => _id;
  String get avatar => _avatar;
  String get role => _role;
  String get canCreate => _canCreate;
  String get pushToken => _pushToken;
  String get receiverToken => _reciverToken;
  String get foreignUser => _foreignUser;

  set updateReceiverToken(String token) {
    _reciverToken = token;
    notifyListeners();
  }

  set updatePushToken(String push) {
    _pushToken = push;
    notifyListeners();
  }


  set updateNameNotify(String name) {
    _name = name;
    notifyListeners();
  }

  set updateBearer(String bearer) {
    _bearer = bearer;
    notifyListeners();
  }

  set updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  set updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  set updateId(String id) {
    _id = id;
    notifyListeners();
  }

  set foreignStatus(String foreignUser) {
    _foreignUser = foreignUser;
    notifyListeners();
  }

  set updateAvatar(String avatar) {
    _avatar = avatar;
    notifyListeners();
  }

  set updateRole(String role) {
    _role = role;
    notifyListeners();
  }

  set updateCancreate(String canCreate) {
    _canCreate = canCreate;
    notifyListeners();
  }
}

class SearchResultsState extends ChangeNotifier {
  List<PostModel> postSearch = [];
  void searchResults(List<PostModel> post) {
    postSearch = post;
    notifyListeners();
  }

  void serachResultsClear() {
    postSearch.clear();
    notifyListeners();
  }
}

class SentFriendRequestState extends ChangeNotifier {
  List<FriendRequestModel> sentFriendRequests = [];
  void setSentRequests(List<FriendRequestModel> newSentFriendRequests) {
    sentFriendRequests = newSentFriendRequests;
    notifyListeners();
  }

  List<FriendRequestModel> getSentRequests() {
    return sentFriendRequests;
  }

  void clearSentRequests() {
    sentFriendRequests.clear();
    notifyListeners();
  }
}

class ReceivedFriendRequestState extends ChangeNotifier {
  List<FriendRequestModel> receivedFriendRequests = [];
  void setReceivedRequests(List<FriendRequestModel> newReceivedFriendRequests) {
    receivedFriendRequests = newReceivedFriendRequests;
    notifyListeners();
  }

  List<FriendRequestModel> getReceivedRequests() {
    return receivedFriendRequests;
  }

  void clearReceivedRequests() {
    receivedFriendRequests.clear();
    notifyListeners();
  }
}

class FriendsListState extends ChangeNotifier {
  List<FriendsModel> friendsList = [];
  void setFriendList(List<FriendsModel> newFriendsList) {
    friendsList = newFriendsList;
    notifyListeners();
  }

  List<FriendsModel> getFriendList() {
    return friendsList;
  }

  void clearFriendList() {
    friendsList.clear();
    notifyListeners();
  }
}

enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  final storage = new FlutterSecureStorage();
  ThemeData currentTheme = darkTheme;
  ThemeType _themeType = ThemeType.Dark;
  toggleTheme() {
    if (_themeType == ThemeType.Dark) {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      storage.write(key: "theme", value: "light");
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      storage.write(key: "theme", value: "dark");
      return notifyListeners();
    }
  }

  setTheme({type}) {
    if (type == 'light') {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      return notifyListeners();
    } else if (type == 'dark') {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    } else {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }
  }
}
