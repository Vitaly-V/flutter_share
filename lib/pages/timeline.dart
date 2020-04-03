import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post.dart' as post_model;
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'home.dart';
import 'post.dart';

class Timeline extends StatefulWidget {
  final User currentUser;

  const Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

  @override
  initState() {
    super.initState();
    getTimeline();
  }

  Future<void> getTimeline() async {
    final QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        //.orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      posts = snapshot.documents
          .map(
              (DocumentSnapshot doc) => Post(post_model.Post.fromDocument(doc)))
          .toList();
    });
  }

  Widget buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return const Text('No posts');
    }
    return ListView(
      children: posts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: RefreshIndicator(
          onRefresh: getTimeline,
          child: buildTimeline(),
        ));
  }
}
