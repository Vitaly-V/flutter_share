import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/custom_image.dart';

import '../models/post.dart' as post_model;
import '../models/user.dart';
import '../widgets/progress.dart';
import 'home.dart';

class Post extends StatelessWidget {
  final post_model.Post post;

  const Post(this.post);

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

  Widget buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('liking post'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[cachedNetworkImage(post.mediaUrl)],
      ),
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
              onTap: () => print('liking post'),
              child: Icon(
                Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, right: 20),
            ),
            GestureDetector(
              onTap: () => print('show comments'),
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
                getLikeCount(post).toString() + ' likes',
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
