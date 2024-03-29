import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/user_model.dart' as model;
import 'package:twitch_clone/providers/user_provider.dart';
import 'package:twitch_clone/widgets/custom_snackbar.dart';

class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserData(String? uid) async {
    if (uid != null) {
      final snap = await _userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

  Future<bool> signUpUser(
    BuildContext context,
    String email,
    String username,
    String password,
  ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        model.User user = model.User(
            uid: cred.user!.uid,
            username: username.trim(),
            email: email.trim());
        await _userRef.doc(cred.user!.uid).set(user.toMap());
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      snackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUser(
            model.User.fromMap(await getUserData(cred.user!.uid) ?? {}));
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      snackBar(context, e.message!);
    }
    return res;
  }
}
