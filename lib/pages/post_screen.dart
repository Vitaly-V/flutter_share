import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post.dart' as post_model;
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'home.dart';
import 'post.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final post_model.Post post =
            post_model.Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context,
                titleText: post.description, showBackButton: true),
            body: ListView(
              children: <Widget>[
                Container(
                  child: Post(post),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
