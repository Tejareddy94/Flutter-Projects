import 'package:intl/intl.dart';

class DateFormatter {
  static String serverTimeFormatter(String server) {
    var now = new DateTime.now();
    var format = new DateFormat('MMM d,yy');
    DateTime utc = DateTime.parse(server);
    DateTime date = utc.toLocal();
    var diff = now.difference(date);
    var time = '';
    if (diff.inSeconds >= 1 && diff.inSeconds <= 60) {
      time="${diff.inSeconds} seconds ago";
    } else if (diff.inMinutes >= 1 && diff.inMinutes <= 60) {
      time = diff.inMinutes == 1
          ? "${diff.inMinutes} minute ago"
          : "${diff.inMinutes} minutes ago";
    } else if (diff.inHours >= 1 && diff.inHours <= 23) {
      time = diff.inHours == 1
          ? "${diff.inHours} hour ago"
          : "${diff.inHours} hours ago";
    } else if (diff.inDays >= 1 && diff.inDays <= 4) {
      time =
          diff.inDays == 1 ? "${diff.inDays} day ago" : "${diff.inDays} days ago";
    } else {
      time = "${format.format(date)}";
    }
    return time;
  }
    static String commentServerTimeFormatter(String server) {
    var now = new DateTime.now();
    var format = new DateFormat('MMM d,yy');
    DateTime utc = DateTime.parse(server);
    DateTime date = utc.toLocal();
    var diff = now.difference(date);
    var time = '';
    if(diff.inMilliseconds>=1 && diff.inMilliseconds <=999){
      time = "${diff.inSeconds}ms";
    }
    else if (diff.inSeconds >= 1 && diff.inSeconds <= 60) {
      time="${diff.inSeconds}s";
    } else if (diff.inMinutes >= 1 && diff.inMinutes <= 60) {
        time =  "${diff.inMinutes}m";
    } else if (diff.inHours >= 1 && diff.inHours <= 23) {
      time ="${diff.inHours}h";
    } else if (diff.inDays >= 1 && diff.inDays <= 4) {
      time ="${diff.inDays}d";
    } else {
      time = "${format.format(date)}";
    }
    return time;
  }
}
