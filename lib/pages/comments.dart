import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'home.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  const Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  final TextEditingController commentsController = TextEditingController();

  Widget buildComments() {
    return StreamBuilder<void>(
        stream: commentsRef
            .document(widget.postId)
            .collection('comments')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Comment> comments = <Comment>[];
          snapshot.data.documents.forEach((DocumentSnapshot doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  void addComment() {
    commentsRef
        .document(widget.postId)
        .collection('comments')
        .add(<String, dynamic>{
      'username': currentUser.username,
      'comment': commentsController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    if (widget.postOwnerId != currentUser.id) {
      activityFeedRef
          .document(widget.postOwnerId)
          .collection('feedItems')
          .add(<String, dynamic>{
        'type': 'comment',
        'commentData': commentsController.text,
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': widget.postId,
        'mediaUrl': widget.postMediaUrl,
        'timestamp': timestamp,
      });
    }
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Comments',
        showBackButton: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentsController,
              decoration:
                  const InputDecoration(labelText: 'Write a comment...'),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: const Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'] as String,
      userId: doc['userId'] as String,
      comment: doc['comment'] as String,
      timestamp: doc['timestamp'] as Timestamp,
      avatarUrl: doc['avatarUrl'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
