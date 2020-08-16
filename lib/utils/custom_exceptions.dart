class LoginException implements Exception {
  String message;
  LoginException(this.message);

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("Admin Login Exception");
    if (message.isNotEmpty) {
      sb.write(": $message");
    } else {
      sb.write("Admin cannot login");
    }
    return sb.toString();
  }
}

class SessionTimeOutException implements Exception {
  String message;
  SessionTimeOutException({this.message="Login Expired"});

  String toString() {
    StringBuffer sb = new StringBuffer();
    if (message != null) {
      if (message.isNotEmpty) {
        sb.write("$message");
      }
    } else {
      sb.write("Login Expired");
    }
    return sb.toString();
  }
}
