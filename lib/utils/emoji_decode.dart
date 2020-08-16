library emojidecode;

import 'dart:convert';

String stringToEmoji(String text) {
  var converted;
  List<int> bytes = text.toString().codeUnits;
  try {
    converted = utf8.decode(bytes);
    return converted;
  } on FormatException catch (e) {
    return text;
  } catch (e) {
    return text;
  }
}
