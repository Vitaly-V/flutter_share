import 'package:flutter/material.dart';

import '../models/post.dart';
import '../pages/post_screen.dart';
import 'custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile(this.post);

  void showPost(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
