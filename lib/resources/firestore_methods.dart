import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/live_stream_model.dart';
import 'package:twitch_clone/providers/user_provider.dart';
import 'package:twitch_clone/resources/storage_methods.dart';
import 'package:twitch_clone/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firebaseStorage = FirebaseFirestore.instance;
  final StorageMethods _storeMethods = StorageMethods();

  Future<String> goToLive(
      BuildContext context, String title, Uint8List? image) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        if (!((await _firebaseStorage
                .collection('livestream')
                .doc('${user.user.uid}${user.user.username}')
                .get())
            .exists)) {
          String thumbnail = await _storeMethods.uploadImage(
              'Thumbnail', image, user.user.uid);
          channelId = '${user.user.uid}${user.user.username}';
          LiveStream liveStream = LiveStream(
              title: title,
              image: thumbnail,
              uid: user.user.uid,
              username: user.user.username,
              startedAt: DateTime.now(),
              viewers: 0,
              channelId: channelId);
          _firebaseStorage
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());
        } else {
          // ignore: use_build_context_synchronously
          snackBar(context, 'Can not start Second Live Stream at a same time');
        }
      } else {
        snackBar(context, 'Kindly Fill All The Fields');
      }
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      snackBar(context, e.message!);
    }
    return channelId;
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firebaseStorage.collection('livestream').doc(id).update({
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> chat(String text, String id, BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    try {
      String commentId = const Uuid().v1();

      _firebaseStorage
          .collection('livestream')
          .doc(id)
          .collection('comments')
          .doc(commentId)
          .set({
        'username': user.user.username,
        'message': text,
        'uid': user.user.uid,
        'createdAt': DateTime.now(),
        'commentId': commentId
      });
    } on FirebaseException catch (e) {
      snackBar(context, e.message!);
    }
  }

  Future<void> endLiveStream(String channelId) async {
    try {
      QuerySnapshot snap = await _firebaseStorage
          .collection('livestream')
          .doc(channelId)
          .collection('comments')
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firebaseStorage
            .collection('livestream')
            .doc(channelId)
            .collection('comments')
            .doc(
              ((snap.docs[i].data()! as dynamic)['commentId']),
            )
            .delete();
      }
      await _firebaseStorage.collection('livestream').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
