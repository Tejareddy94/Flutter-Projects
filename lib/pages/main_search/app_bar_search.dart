import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/search_post_widget.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/post/search_widget.dart';
import 'package:r2a_mobile/shared/shimmering_effect.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class MainSearch extends SearchDelegate<String> {
  final storage = new FlutterSecureStorage();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          color: Theme.of(context).iconTheme.color,
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
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).appBarTheme.iconTheme.color,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchWidget(
      query: query,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    SearchResultsState recentPosts = Provider.of<SearchResultsState>(context);
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: recentPosts.postSearch.length + 1,
      itemBuilder: (context, index) {
        if (index == recentPosts.postSearch.length) {
          if (recentPosts.postSearch.length == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                EmptyDataWidget(),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Text(
                    "Search For Posts",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        } else {
          return SearchPost(
            post: recentPosts.postSearch[index],
            index: index,
          );
        }
      },
    );
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
          theme.textTheme.copyWith(headline6: TextStyle(color: Theme.of(context).textTheme.headline1.color)),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: Theme.of(context)
              .textTheme
              .headline1
              .copyWith(color: Theme.of(context).textTheme.caption.color),
          labelStyle: Theme.of(context).textTheme.headline1,
        ),
      );
  }
}
