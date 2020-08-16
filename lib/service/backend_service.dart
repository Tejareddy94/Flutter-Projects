import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:r2a_mobile/env/app_config.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/custom_exceptions.dart';

class BackendService {
//  BackendService({this.context, this.endPoint, this.body, this.header});
//  final context;
//  final endPoint;
//  final header;
//  final body;

  static get(String endPoint, Map<String, String> header, context,
      {String route = "/"}) async {
    final storage = new FlutterSecureStorage();
    UserState userState = Provider.of<UserState>(context, listen: true);

    final Map<String, String> contentHeaders = {
      "Content-type": "application/json"
    };
    var connectivityResult = await (Connectivity().checkConnectivity());

    var config = AppConfig.of(context);

    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      Map<String, String> finalHeaders = {};
      // Check if extra headers are provided for authorization and stuff
      if (header.isEmpty) {
        finalHeaders.addAll(contentHeaders);
      } else {
        finalHeaders.addAll(contentHeaders);
        finalHeaders.addAll(header);
      }

      try {
        final response =
            await http.get(config.baseUrl + endPoint, headers: finalHeaders);
        var body = jsonDecode(response.body);
        if (response.statusCode == 401) {
          throw new SessionTimeOutException();
        } else if (response.statusCode == 200) {
          return response;
        }
      } on SessionTimeOutException catch (e) {
        await storage.deleteAll();
        userState.setUserDetails(
            name: "",
            avatar: "",
            bearer: "",
            phoneNumber: "",
            canCreate: "",
            email: "",
            id: "",
            role: "");
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
        throw new SessionTimeOutException();
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } on NoSuchMethodError catch (e) {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Sorry Something went wrong",
          ),
        );
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } catch (err) {
        showDialog(
          context: context,
          builder: (_) => CustomAlertRoundedBox(
            message: "Sorry something went wrong",
          ),
        );
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops', arguments: route);
      throw new Exception("No Internet");
    }
  }

  static post(String endPoint, Map<String, String> header, body, context,
      {String route = "/"}) async {
    final storage = new FlutterSecureStorage();
    UserState userState = Provider.of<UserState>(context, listen: true);

    final Map<String, String> contentHeaders = {
      "Content-type": "application/json"
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    var config = AppConfig.of(context);

    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      Map<String, String> finalHeaders = {};
      if (header.isEmpty) {
        finalHeaders.addAll(contentHeaders);
      } else {
        finalHeaders.addAll(contentHeaders);
        finalHeaders.addAll(header);
      }
      try {
        final response = await http.post(config.baseUrl + endPoint,
            headers: finalHeaders, body: jsonEncode(body));
        if (response.statusCode == 401) {
          throw new SessionTimeOutException();
        } else if (response.statusCode == 200) {
          return response;
        }
      } on SessionTimeOutException catch (e) {
        await storage.deleteAll();
        userState.setUserDetails(
            name: "",
            avatar: "",
            bearer: "",
            phoneNumber: "",
            canCreate: "",
            email: "",
            id: "",
            role: "");
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
        throw new SessionTimeOutException();
      } on NoSuchMethodError catch (e) {
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } catch (err) {
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops', arguments: route);
      throw new Exception("No Internet");
    }
  }

  static authPost(String endPoint, Map<String, String> header, body, context,
      {String route = "/"}) async {
    final Map<String, String> contentHeaders = {
      "Content-type": "application/json"
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    var config = AppConfig.of(context);

    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      Map<String, String> finalHeaders = {};
      if (header.isEmpty) {
        finalHeaders.addAll(contentHeaders);
      } else {
        finalHeaders.addAll(contentHeaders);
        finalHeaders.addAll(header);
      }
      try {
        final response = await http.post(config.baseUrl + endPoint,
            headers: finalHeaders, body: jsonEncode(body));
        var _data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 401) {
          throw new LoginException(_data['detail']);
        } else if (response.statusCode == 400) {
          if (_data.containsKey("email")) {
            throw new LoginException("user with this email already exists.");
          }
        }
      } on LoginException catch (e) {
        throw new LoginException(e.message);
      } on NoSuchMethodError catch (e) {
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } catch (err) {
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops');
      throw new Exception("No Internet");
    }
  }

  static put(String endPoint, Map<String, String> header, body, context,
      {String route = "/"}) async {
    final storage = new FlutterSecureStorage();
    UserState userState = Provider.of<UserState>(context, listen: true);

    final Map<String, String> contentHeaders = {
      "Content-type": "application/json"
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    var config = AppConfig.of(context);

    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      Map<String, String> finalHeaders = {};
      if (header.isEmpty) {
        finalHeaders.addAll(contentHeaders);
      } else {
        finalHeaders.addAll(contentHeaders);
        finalHeaders.addAll(header);
      }
      try {
        final response = await http.put(config.baseUrl + endPoint,
            headers: finalHeaders, body: jsonEncode(body));
        if (response.statusCode == 401) {
          throw new SessionTimeOutException();
        } else if (response.statusCode == 200) {
          return response;
        }
      } on SessionTimeOutException catch (e) {
        await storage.deleteAll();
        userState.setUserDetails(
            name: "",
            avatar: "",
            bearer: "",
            phoneNumber: "",
            canCreate: "",
            email: "",
            id: "",
            role: "");
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
        throw new SessionTimeOutException();
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } on NoSuchMethodError catch (e) {
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } catch (err) {
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops', arguments: route);
      throw new Exception("No Internet");
    }
  }

  static delete(String endPoint, Map<String, String> header, context,
      {String route = "/"}) async {
    final storage = new FlutterSecureStorage();
    UserState userState = Provider.of<UserState>(context, listen: true);
    final Map<String, String> contentHeaders = {
      "Content-type": "application/json"
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    var config = AppConfig.of(context);

    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      Map<String, String> finalHeaders = {};
      if (header.isEmpty) {
        finalHeaders.addAll(contentHeaders);
      } else {
        finalHeaders.addAll(contentHeaders);
        finalHeaders.addAll(header);
      }
      try {
        final response =
            await http.delete(config.baseUrl + endPoint, headers: finalHeaders);
        if (response.statusCode == 401) {
          throw new SessionTimeOutException();
        } else if (response.statusCode == 200) {
          return response;
        }
      } on SessionTimeOutException catch (e) {
        await storage.deleteAll();
        userState.setUserDetails(
            name: "",
            avatar: "",
            bearer: "",
            phoneNumber: "",
            canCreate: "",
            email: "",
            id: "",
            role: "");
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
        throw new SessionTimeOutException();
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } on NoSuchMethodError catch (e) {
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } catch (err) {
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops', arguments: route);
      throw new Exception("No Internet");
    }
  }

  static uplodS3(fileUrl, context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.toString() != 'ConnectivityResult.none') {
      File imageFile = new File(fileUrl);
      List<int> imageBytes = imageFile.readAsBytesSync();
      String bas64Str = base64.encode(imageBytes);
      String name = imageFile.path.split('/').last;
      String fileName = name.split('.')[0];
      String fileExtension = name.split('.')[1];

      final body = {
        "attachment": bas64Str,
        "folder": "profilePictures",
        "attachment_type": "." + fileExtension,
        "attachment_name": fileName
      };
      try {
        final response = await http.post(
            'https://r2jtyqdibj.execute-api.us-east-2.amazonaws.com/dev/r2a-upload',
            headers: <String, String>{
              "x-api-key": "udweCdGCt5tIEVT0CmEL2dThLAq3EIO5A87tQiic"
            },
            body: jsonEncode(body));
        return response;
      } on SocketException catch (e) {
        throw new SocketException("Unable to Reach Server at this moment");
      } on NoSuchMethodError catch (e) {
        return {"status": 'error', 'message': 'error on NoSuchMethod'};
      } on FormatException catch (e) {
        return {"status": 'error', 'message': 'error on format exception'};
      } catch (err) {
        return {"status": 'error', 'message': 'error'};
      }
    } else {
      Navigator.pushNamed(context, '/oops');
      throw new Exception("No Internet");
    }
  }
}
