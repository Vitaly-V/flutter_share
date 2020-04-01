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
