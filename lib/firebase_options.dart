import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDV-9L-sKfK6W80ITIeU2F_4EiHoxNV3Wk',
    appId: '1:120005503166:web:5ba9bb6b6947da816716ef',
    messagingSenderId: '120005503166',
    projectId: 'ultra-signals-1',
    authDomain: 'ultra-signals-1.firebaseapp.com',
    storageBucket: 'ultra-signals-1.firebasestorage.app',
    measurementId: 'G-CR4EBLXRKG',
  );
}