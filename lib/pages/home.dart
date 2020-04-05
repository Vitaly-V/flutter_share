import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';
import '../widgets/progress.dart';
import 'activity_feed.dart';
import 'create_account.dart';
import 'profile.dart';
import 'search.dart';
import 'timeline.dart';
import 'upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final CollectionReference userRef = Firestore.instance.collection('users');
final CollectionReference postRef = Firestore.instance.collection('posts');
final CollectionReference commentsRef =
    Firestore.instance.collection('comments');
final CollectionReference activityFeedRef =
    Firestore.instance.collection('feed');
final CollectionReference followersRef =
    Firestore.instance.collection('followers');
final CollectionReference followingRef =
    Firestore.instance.collection('following');
final CollectionReference timelineRef =
    Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  final DateTime timestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen(
        (GoogleSignInAccount account) => handleSignIn(account),
        onError: (Object err) => print('Error signing in: $err'));
    // Reauthenticate user when app is opened
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((GoogleSignInAccount account) => handleSignIn(account))
        .catchError((Object err) => print('Error signing in: $err'));
  }

  Future<void> handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Future<void> configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) {
      getIOSPermission();
    }
    _firebaseMessaging.getToken().then((String token) {
      userRef
          .document(user.id)
          .updateData(<String, String>{'androidNotificationToken': token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        final String recipientId = message['data']['recipient'] as String;
        final String body = message['notification']['body'] as String;
        if (recipientId == user.id) {
          final SnackBar snackBar = SnackBar(
            content: Text(
              body,
              overflow: TextOverflow.ellipsis,
            ),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  void getIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  Future<void> createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    if (!doc.exists) {
      final dynamic username = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => CreateAccount(),
        ),
      );
      userRef.document(user.id).setData(<String, dynamic>{
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });

      doc = await userRef.document(user.id).get();
      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData(<String, String>{});
    }
    setState(() {
      currentUser = User.fromDocument(doc);
    });
  }

  void login() {
    googleSignIn.signIn();
  }

  void logout() {
    googleSignIn.signOut();
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  Widget buildAuthScreen() {
    if (currentUser == null) {
      return circularProgress();
    }
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
          /* RaisedButton(
          child: const Text('Logout'),
          onPressed: logout,
        ),*/
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  void onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
