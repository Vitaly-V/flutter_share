import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'] as String,
      email: doc['email'] as String,
      username: doc['username'] as String,
      photoUrl: doc['photoUrl'] as String,
      displayName: doc['displayName'] as String,
      bio: doc['bio'] as String,
    );
  }
}
