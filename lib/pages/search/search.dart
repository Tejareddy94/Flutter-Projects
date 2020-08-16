import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/search/search_result.dart';

class DataSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          focusColor: Colors.black,
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResult(query: query);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
       backgroundColor: Colors.white,
      primaryColor: Theme.of(context).appBarTheme.color,
      appBarTheme: Theme.of(context).appBarTheme,
      textTheme:
          theme.textTheme.copyWith(headline6: TextStyle(color: Theme.of(context).textSelectionColor)),
      inputDecorationTheme: InputDecorationTheme(
          focusColor: Theme.of(context).textSelectionColor,
          hintStyle: TextStyle(color: Theme.of(context).bottomAppBarColor)),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchResult(query: query);
  }
}
