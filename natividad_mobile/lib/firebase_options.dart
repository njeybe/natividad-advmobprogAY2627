// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// LAB ACT 5 - ENHANCEMENT 1: Firebase initialization options. The per-app
/// `apiKey` and `appId` credentials are never hard-coded here; they are read at
/// runtime from the git-ignored `assets/.env` so that no credential literal is
/// ever committed to version control.
class DefaultFirebaseOptions {
  static String _env(String key) {
    if (!dotenv.isInitialized) {
      throw StateError(
        'dotenv has not been loaded. Call `await dotenv.load(fileName: '
        '"assets/.env")` before Firebase.initializeApp().',
      );
    }

    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in assets/.env. Copy the provided template to '
        'assets/.env and fill in your Firebase configuration.',
      );
    }
    return value;
  }

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _env('FIREBASE_WEB_API_KEY'),
    appId: _env('FIREBASE_WEB_APP_ID'),
    messagingSenderId: '730778635582',
    projectId: 'advmobprog-firebase-2cba3',
    authDomain: 'advmobprog-firebase-2cba3.firebaseapp.com',
    storageBucket: 'advmobprog-firebase-2cba3.firebasestorage.app',
    measurementId: 'G-B86QYJGSJ2',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _env('FIREBASE_ANDROID_API_KEY'),
    appId: _env('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: '730778635582',
    projectId: 'advmobprog-firebase-2cba3',
    storageBucket: 'advmobprog-firebase-2cba3.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _env('FIREBASE_IOS_API_KEY'),
    appId: _env('FIREBASE_IOS_APP_ID'),
    messagingSenderId: '730778635582',
    projectId: 'advmobprog-firebase-2cba3',
    storageBucket: 'advmobprog-firebase-2cba3.firebasestorage.app',
    iosBundleId: 'com.example.natividadMobile',
  );
}
