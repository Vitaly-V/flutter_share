import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post.dart' as post_model;
import '../models/user.dart';
import '../widgets/custom_image.dart';
import '../widgets/progress.dart';
import 'comments.dart';
import 'home.dart';

class Post extends StatefulWidget {
  final post_model.Post post;

  const Post(this.post);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  post_model.Post post;
  int likesCount;
  bool isLiked = false;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    isLiked = widget.post.likes[currentUser?.id] == null
        ? false
        : widget.post.likes[currentUser?.id];
    likesCount = getLikeCount(post);
  }

  int getLikeCount(post_model.Post post) {
    if (post.likes == null) {
      return 0;
    }
    int count = 0;
    post.likes.values.forEach((bool val) {
      if (val) {
        count += 1;
      }
    });
    return count;
  }

  Widget buildPostHeader() {
    return FutureBuilder<void>(
      future: userRef.document(post.ownerId).get(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              user.username,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(post.location),
          trailing: IconButton(
            onPressed: () => print('deliting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  void addLikeToActivityFeed() {
    if (post.ownerId != currentUser.id) {
      activityFeedRef
          .document(post.ownerId)
          .collection('feedItems')
          .document(post.postId)
          .setData(<String, dynamic>{
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': post.postId,
        'mediaUrl': post.mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  void removeLikeFromActivityFeed() {
    if (post.ownerId != currentUser.id) {
      activityFeedRef
          .document(post.ownerId)
          .collection('feedItems')
          .document(post.postId)
          .get()
          .then((DocumentSnapshot doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  void handleLikePost() {
    setState(() {
      if (isLiked != true) {
        isLiked = true;
        likesCount++;
        showHeart = true;
        addLikeToActivityFeed();
      } else {
        isLiked = false;
        likesCount--;
        removeLikeFromActivityFeed();
      }
      postRef
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId)
          .updateData(<String, bool>{'likes.${currentUser?.id}': isLiked});
    });
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  Widget buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(post.mediaUrl),
          if (showHeart)
            Animator<dynamic>(
              duration: const Duration(milliseconds: 300),
              tween: Tween<dynamic>(begin: 0.8, end: 1.5),
              curve: Curves.elasticOut,
              cycles: 0,
              builder: (Animation<dynamic> anim) => Transform.scale(
                scale: anim.value as double,
                child: Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.red,
                ),
              ),
            )
        ],
      ),
    );
  }

  void showComments() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<dynamic>(builder: (BuildContext context) {
        return Comments(
          postId: post.postId,
          postOwnerId: post.ownerId,
          postMediaUrl: post.mediaUrl,
        );
      }),
    );
  }

  Widget buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, right: 20),
            ),
            GestureDetector(
              onTap: showComments,
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                '$likesCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                '${post.username} ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(post.description),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
