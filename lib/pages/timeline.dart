import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/header.dart';
import '../widgets/progress.dart';

final CollectionReference userRer = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    // Dummy query...
    final QuerySnapshot snapshot = await userRer
        .where('isAdmin', isEqualTo: true)
        .where('postsCount', isGreaterThan: 1)
        .orderBy('postsCount', descending: false)
        .limit(1)
        .getDocuments();
    snapshot.documents.forEach((DocumentSnapshot doc) {
      print(doc.data);
      print(doc.documentID);
      print(doc.exists);
    });
  }

  void getUserById() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: linearProgress(),
    );
  }
}
