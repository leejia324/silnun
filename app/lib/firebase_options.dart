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
      default:
        throw UnsupportedError(
          '지원하지 않는 플랫폼입니다: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCj-WE_pOiKkuHhvBdr7l7XVOfEhFAI374',
    appId: '1:926665822985:web:9ba6892804be078e64f9d8',
    messagingSenderId: '926665822985',
    projectId: 'silnun',
    authDomain: 'silnun.firebaseapp.com',
    storageBucket: 'silnun.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnXyg0P5R1uhIKQAIQRPLFHdV5UJcdk-s',
    appId: '1:926665822985:android:d4596678a2c25db664f9d8',
    messagingSenderId: '926665822985',
    projectId: 'silnun',
    storageBucket: 'silnun.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCA2DylOQ1V9jH9WPz8vv8rBfS0vvaRMBE',
    appId: '1:926665822985:ios:99a606314c85c15664f9d8',
    messagingSenderId: '926665822985',
    projectId: 'silnun',
    storageBucket: 'silnun.firebasestorage.app',
    iosBundleId: 'com.silnun.app',
  );
}
