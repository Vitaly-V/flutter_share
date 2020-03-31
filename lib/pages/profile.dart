import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post.dart' as post_model;
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/post_tile.dart';
import '../widgets/progress.dart';
import 'edit_profile.dart';
import 'home.dart';
import 'post.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  bool isGridOrientation = true;
  bool isLoading = false;
  int postCount = 0;
  List<post_model.Post> posts;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  Future<void> getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    final QuerySnapshot snapshot = await postRef
        .document(widget.profileId)
        .collection('userPosts')
        //.orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents
          .map((doc) => post_model.Post.fromDocument(doc))
          .toList();
    });
  }

  Widget buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  void editProfile() {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) =>
            EditProfile(currentUserId: currentUserId),
      ),
    );
  }

  Widget buildButton({String text, Function function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: () => function(),
        child: Container(
          width: 250,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget buildProfileButton() {
    final bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    }
  }

  Widget buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    }
    if (isGridOrientation) {
      final List<GridTile> gridTiles = [];
      posts.forEach((post_model.Post post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else {
      return Column(
        children: posts.map((post_model.Post post) => Post(post)).toList(),
      );
    }
  }

  Widget buildProfileHeader() {
    return FutureBuilder<dynamic>(
      future: userRef.document(widget.profileId).get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(
                      user.photoUrl,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('followers', 0),
                            buildCountColumn('following', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void togglePostOrientation() {
    setState(() {
      isGridOrientation = !isGridOrientation;
    });
  }

  Widget buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: isGridOrientation
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: togglePostOrientation,
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: isGridOrientation
                ? Colors.grey
                : Theme.of(context).primaryColor,
          ),
          onPressed: togglePostOrientation,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          const Divider(),
          buildTogglePostOrientation(),
          const Divider(
            height: 0,
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}
