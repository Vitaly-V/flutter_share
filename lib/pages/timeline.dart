import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/search.dart';

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
  List<String> followingList = [];

  @override
  initState() {
    super.initState();
    getTimeline();
    getFollowing();
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

  Future<void> getFollowing() async {
    final QuerySnapshot snapshot = await followingRef
        .document(widget.currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingList = snapshot.documents
          .map((DocumentSnapshot doc) => doc.documentID)
          .toList();
    });
  }

  StreamBuilder<dynamic> buildUsersToFollow() {
    return StreamBuilder<dynamic>(
      stream:
          userRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final List<UserResult> userResults = <UserResult>[];
        snapshot.data.documents.forEach((DocumentSnapshot doc) {
          final User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          if (isAuthUser) {
            return null;
          } else if (followingList.contains(user.id)) {
            return null;
          }
          userResults.add(UserResult(user));
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        'Users to Follow',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults),
              ],
            ),
          );
        });
        return null;
      },
    );
  }

  Widget buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
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
