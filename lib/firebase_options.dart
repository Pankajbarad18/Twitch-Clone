// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgxog-yQPsaXbFl5sOOXrIHV_V6J5alqk',
    appId: '1:431528007815:web:81f13713907d32a1644022',
    messagingSenderId: '431528007815',
    projectId: 'twitch-clone-1806',
    authDomain: 'twitch-clone-1806.firebaseapp.com',
    storageBucket: 'twitch-clone-1806.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqV5K_pIO5-MLk9M8rPIl7a-ckUGKQ-h8',
    appId: '1:431528007815:android:bcf087a0fd0b0b41644022',
    messagingSenderId: '431528007815',
    projectId: 'twitch-clone-1806',
    storageBucket: 'twitch-clone-1806.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6PlHhRN2j2hf_XphdusxJWGZtePZ3Fz8',
    appId: '1:431528007815:ios:a85f0ae0286d2c08644022',
    messagingSenderId: '431528007815',
    projectId: 'twitch-clone-1806',
    storageBucket: 'twitch-clone-1806.appspot.com',
    iosBundleId: 'com.example.twitchClone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB6PlHhRN2j2hf_XphdusxJWGZtePZ3Fz8',
    appId: '1:431528007815:ios:055ddfb3160d3ca4644022',
    messagingSenderId: '431528007815',
    projectId: 'twitch-clone-1806',
    storageBucket: 'twitch-clone-1806.appspot.com',
    iosBundleId: 'com.example.twitchClone.RunnerTests',
  );
}