//theme.dart

import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Color(0xFF363940),
      textTheme:
          TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 18.0)),
      elevation: 1.0,
      iconTheme: IconThemeData(color: Colors.white70),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF535bec),
      foregroundColor: Colors.white,
    ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF363940),
    selectedItemColor: Color(0xFF535bec),
    unselectedItemColor: Colors.grey[800],
    elevation: 1,
    unselectedIconTheme: IconThemeData(
      color: Colors.grey[600],
    ),
    selectedIconTheme: IconThemeData(
      color: Color(0xFF535bec),
    ),
  ),
    cardColor: Color(0xFF303136), 
    cardTheme: CardTheme(color: Color(0xFF20274d)),
    canvasColor: Color(0xFF2F3338),
    iconTheme: IconThemeData(color: Color(0xFFbabbbf), size: 24.0),
    dividerColor: Colors.white38,
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 14, color: Colors.white),
      headline2: TextStyle(fontSize: 17, color: Colors.white),
      headline3: TextStyle(fontSize: 19, color: Colors.white),
      headline4: TextStyle(fontSize: 35, color: Colors.white),
      headline5: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
      subtitle1: TextStyle(color: Colors.white),
      caption: TextStyle(color: Colors.white54),
      bodyText2: TextStyle(color: Colors.white70),
      headline6: TextStyle(color: Colors.white),
    ),
    primaryColor: Color(0xFF535bec),
    accentColor: Colors.black,
    textSelectionColor: Colors.white,
    backgroundColor: Color(0xFF363940),
    buttonColor: Color(0xFF7289d9),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF2F3338),
      filled: true,
    ),
    bottomAppBarColor: Colors.white38,
    popupMenuTheme: PopupMenuThemeData(color: Color(0xFF2a2b2f)));

ThemeData lightTheme = ThemeData(
  accentTextTheme: TextTheme(),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF535bec),
    foregroundColor: Colors.white,
  ),

  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF535bec),
    disabledColor: Colors.white,
    textTheme: ButtonTextTheme.primary,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF535bec),
    unselectedItemColor: Colors.grey[800],
    elevation: 1,
    unselectedIconTheme: IconThemeData(
      color: Colors.grey[600],
    ),
    selectedIconTheme: IconThemeData(
      color: Color(0xFF535bec),
    ),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    textTheme:
        TextTheme(headline6: TextStyle(color: Colors.black, fontSize: 18.0)),
    elevation: 1.0,
    iconTheme: IconThemeData(color: Colors.black87),
  ),
  cardColor: Colors.white,
  cardTheme: CardTheme(color: Color(0xFF535bec)),
  iconTheme: IconThemeData(color: Colors.black, size: 24.0),
  dividerColor: Colors.black38,
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 14, color: Colors.black),
    headline2: TextStyle(fontSize: 17, color: Colors.black),
    headline3: TextStyle(fontSize: 19, color: Colors.black),
    headline4: TextStyle(fontSize: 35, color: Colors.black),
    headline5: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
    subtitle1: TextStyle(color: Colors.black),
    caption: TextStyle(color: Colors.black54),
    bodyText2: TextStyle(color: Colors.black87),
    headline6: TextStyle(color: Colors.black),
  ),
  primaryColor: Color(0xFF535bec),
  accentColor: Colors.white,
  textSelectionColor: Colors.black,
  backgroundColor: Colors.grey[200],
  buttonColor: Color(0xFF535bec),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white70,
    filled: false,
  ),
  bottomAppBarColor: Colors.black38,
  popupMenuTheme: PopupMenuThemeData(color: Colors.white),
);
