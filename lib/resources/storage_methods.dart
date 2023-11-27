import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadImage(
    String childName,
    Uint8List file,
    String uid,
  ) async {
    Reference ref = _firebaseStorage.ref().child(childName).child(uid);
    UploadTask uploadTask =
        ref.putData(file, SettableMetadata(contentType: 'image/jpg'));

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
