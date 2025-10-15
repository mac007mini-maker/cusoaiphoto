import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2VGc-o0LbF10JHn-nRU53chEY5FiXO_c',
    appId: '1:987545828793:web:8ae2e8f8feda5c44bb4a68',
    messagingSenderId: '987545828793',
    projectId: 'viso-ai-photo-avatar',
    authDomain: 'viso-ai-photo-avatar.firebaseapp.com',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
    measurementId: 'G-ETCJCW0GDT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbqiWSgg7FqVt3luFUerAibXk97lnxYaE',
    appId: '1:987545828793:android:7c1fbb39b74255a4bb4a68',
    messagingSenderId: '987545828793',
    projectId: 'viso-ai-photo-avatar',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATFSyLkOYrpLvQ87Qu6_grUUkmuBaL9ak',
    appId: '1:987545828793:ios:836edababf0b4769bb4a68',
    messagingSenderId: '987545828793',
    projectId: 'viso-ai-photo-avatar',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
    iosBundleId: 'com.visoai.photoheadshot',
  );
}
