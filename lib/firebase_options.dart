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
    apiKey: 'AIzaSyA41ACqTA0csL8Hs-JfIUaT6w_UQ4M366M',
    appId: '1:807368771566:web:3b88c16b78f83cdc2bb0ff',
    messagingSenderId: '807368771566',
    projectId: 'drop-n-go',
    authDomain: 'drop-n-go.firebaseapp.com',
    storageBucket: 'drop-n-go.appspot.com',
    measurementId: 'G-P87R29SDF0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlDA6e_tymSuGdvSX7aLNth2mdkEzFPQA',
    appId: '1:807368771566:android:63db2987b95f9a832bb0ff',
    messagingSenderId: '807368771566',
    projectId: 'drop-n-go',
    storageBucket: 'drop-n-go.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCR-zQxm7rUGLy9BqkjsFIaQAa2TbKlKtA',
    appId: '1:807368771566:ios:11329ec0630237e02bb0ff',
    messagingSenderId: '807368771566',
    projectId: 'drop-n-go',
    storageBucket: 'drop-n-go.appspot.com',
    iosClientId: '807368771566-aocar351grhf0tgem7flkvok4jmb46q3.apps.googleusercontent.com',
    iosBundleId: 'com.example.dropNGo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCR-zQxm7rUGLy9BqkjsFIaQAa2TbKlKtA',
    appId: '1:807368771566:ios:11329ec0630237e02bb0ff',
    messagingSenderId: '807368771566',
    projectId: 'drop-n-go',
    storageBucket: 'drop-n-go.appspot.com',
    iosClientId: '807368771566-aocar351grhf0tgem7flkvok4jmb46q3.apps.googleusercontent.com',
    iosBundleId: 'com.example.dropNGo',
  );
}