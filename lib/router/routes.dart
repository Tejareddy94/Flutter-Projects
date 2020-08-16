import 'package:flutter/material.dart';
import 'package:r2a_mobile/pages/auth/forgot_password.dart';
import 'package:r2a_mobile/pages/auth/home_page.dart';
import 'package:r2a_mobile/pages/auth/login.dart';
import 'package:r2a_mobile/pages/auth/otp_login.dart';
import 'package:r2a_mobile/pages/auth/sign_up.dart';
import 'package:r2a_mobile/pages/auth/validate_phone.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/add_posts.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/news_feed.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/my_medical.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/my_political.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/profile.dart';
import 'package:r2a_mobile/pages/friend/friends.dart';
import 'package:r2a_mobile/pages/friend/user_news_feed.dart';
import 'package:r2a_mobile/pages/main_page.dart';
import 'package:r2a_mobile/pages/no_internet.dart';
import 'package:r2a_mobile/pages/friend/user_profile.dart';
import 'package:r2a_mobile/pages/user/edit_profile.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/my_constituency_posts.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/my_district_posts.dart';
import 'package:r2a_mobile/pages/user/change_password.dart';
import 'package:r2a_mobile/spalsh_screen.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/settings.dart';
import 'package:r2a_mobile/pages/drawer/drawer_items/my_news_feed.dart';
import 'package:r2a_mobile/pages/auth/email_login.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //Pass arguments to any page
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/validate':
        return MaterialPageRoute(builder: (_) => ValidatePhone());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpScreen(args: args));
      case '/oops':
        return MaterialPageRoute(
            builder: (_) => NoInternet(route: settings.arguments));
      case '/newsfeed':
        return MaterialPageRoute(builder: (_) => NewsFeed());
      case '/otplogin':
        return MaterialPageRoute(builder: (_) => OtpLogin());
      case '/forgotpassword':
        return MaterialPageRoute(builder: (_) => ForgotPassword());
      case '/mainpage':
        return MaterialPageRoute(builder: (_) => MainPage());
      case '/mysocial':
        return MaterialPageRoute(builder: (_) => MySocialPost());
      case '/mymedical':
        return MaterialPageRoute(builder: (_) => MyMedicalPost());
      case '/profile':
        return MaterialPageRoute(builder: (_) => Profile());
      case '/user_profile':
        return MaterialPageRoute(
            builder: (_) => UserProfile(userId: settings.arguments));
      case '/edit_profile':
        return MaterialPageRoute(
            builder: (_) => EditProfile(userDetails: settings.arguments));
      case '/user_news_feed':
        return MaterialPageRoute(
            builder: (_) => UserNewsFeed(userId: settings.arguments));
      case '/friends':
        return MaterialPageRoute(
            builder: (_) => Friends(currentIndex: settings.arguments));
      case '/my_constituency_posts':
        return MaterialPageRoute(builder: (_) => MyConstituencyPosts());
      case '/my_district_posts':
        return MaterialPageRoute(builder: (_) => MyDistrictPosts());
      case '/change_password':
        return MaterialPageRoute(
            builder: (_) => ChangePassword(bearer: settings.arguments));
      case '/add_posts':
        return MaterialPageRoute(builder: (_) => AddPosts());
      case '/settings':
        return MaterialPageRoute(builder: (_) => Settings());
      case '/my_news_feed':
        return MaterialPageRoute(builder: (_) => MyNewsFeed());
      case '/email_login':
        return MaterialPageRoute(builder: (_) => EmailLogin());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
