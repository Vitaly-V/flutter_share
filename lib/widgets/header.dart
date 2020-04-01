import 'package:flutter/material.dart';

AppBar header(
  BuildContext context, {
  bool isAppTitle = false,
  String titleText,
  bool showBackButton = false,
}) {
  return AppBar(
    automaticallyImplyLeading: showBackButton,
    title: Text(
      isAppTitle ? 'FlutterShare' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50 : 22,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
