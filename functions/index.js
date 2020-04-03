const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onCreateFollower = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserRef = admin
      .firestore()
      .collection('posts')
      .doc(userId)
      .collection('userPosts');

    const timelinePostRef = admin
      .firestore()
      .collection('timeline')
      .doc(userId)
      .collection('timelinePosts');

    const querySnapshot = await followedUserRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostRef.doc(postId).set(postData);
      }
    });
  });

exports.onDeleteFollower = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostRef = admin
      .firestore()
      .collection('timeline')
      .doc(userId)
      .collection('timelinePosts')
      .where('ownerId', '==', userId);

    const querySnapshot = await timelinePostRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

exports.onCreatePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const followerId = doc.id;
        admin.firestore()
          .collection('timeline')
          .doc(followerId)
          .collection('timelinePosts')
          .doc(postId)
          .set(postCreated);
      }
    });
  });

exports.onUpdatePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const followerId = doc.id;
        admin.firestore()
          .collection('timeline')
          .doc(followerId)
          .collection('timelinePosts')
          .doc(postId)
          .get().then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
      }
    });
  });

exports.onDeletePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const followerId = doc.id;
        admin.firestore()
          .collection('timeline')
          .doc(followerId)
          .collection('timelinePosts')
          .doc(postId)
          .get().then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
      }
    });
  });
