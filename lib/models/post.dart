import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Map<String, bool> likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'] as String,
      ownerId: doc['ownerId'] as String,
      username: doc['username'] as String,
      location: doc['location'] as String,
      description: doc['description'] as String,
      mediaUrl: doc['mediaUrl'] as String,
      likes: Map<String, bool>.from(doc['likes'] as Map<dynamic, dynamic>),
    );
  }
}

class Like {}
