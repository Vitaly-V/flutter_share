import 'package:flutter/material.dart';

AppBar header(
  BuildContext context, {
  bool isAppTitle = false,
  String titleText,
  bool removeBackButton = false,
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton,
    title: Text(
      isAppTitle ? 'FlutterShare' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50 : 22,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
