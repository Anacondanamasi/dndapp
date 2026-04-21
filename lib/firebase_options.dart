import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBd_7DON88ZLD1Cz6eO_tsUldHEMT-4RXY',
    appId: '1:928136925150:android:7eac2c5e1594790a9b574f',
    messagingSenderId: '928136925150',
    projectId: 'jewello-8e920',
    storageBucket: 'jewello-8e920.firebasestorage.app',
  );
}
