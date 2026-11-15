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
    apiKey: 'AIzaSyBdRVZ0_Yx3ItWpiToFXgM2UeshQbqwvII',
    appId: '1:772182352528:web:477d3169004a0d5b9d6e15',
    messagingSenderId: '772182352528',
    projectId: 'course-explorer-guntur',
    authDomain: 'course-explorer-guntur.firebaseapp.com',
    storageBucket: 'course-explorer-guntur.firebasestorage.app',
  );
}