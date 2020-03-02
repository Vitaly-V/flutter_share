import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/progress.dart';

import '../widgets/header.dart';

final CollectionReference userRer = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  void getUserById() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRer.snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return Container(
            child: ListView(
              children: snapshot.data.documents
                  .map((dynamic user) => Text(user['username'] as String))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
