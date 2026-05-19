// File ini dihasilkan oleh FlutterFire CLI.
// Ganti nilai di bawah dengan konfigurasi Firebase project Anda.
// Jalankan: flutterfire configure
// Atau isi manual dari Firebase Console > Project Settings.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi Firebase default untuk setiap platform.
///
/// PENTING: Ganti nilai placeholder di bawah ini dengan
/// konfigurasi dari Firebase Console project Anda!
/// Firebase Console → Project Settings → Your apps → google-services.json
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak dikonfigurasi untuk Linux. '
          'Buat konfigurasi baru menggunakan FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak didukung untuk platform ini.',
        );
    }
  }

  // ────────────────────────────────────────────────────
  // GANTI NILAI DI BAWAH DENGAN NILAI DARI FIREBASE CONSOLE
  // Firebase Console → Project Settings → Your Apps
  // ────────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWiO5w2w8_8I9eCkDLZXST-7YO5OVSmpU',
    appId: '1:294574323556:android:48d422c8fc60ab6de72c71',
    messagingSenderId: '294574323556',
    projectId: 'tugas-individu-hermansawira',
    databaseURL: 'https://tugas-individu-hermansawira-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-individu-hermansawira.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCnmq1YyICp_nktQ_e9Inp86UYT_-DyEik',
    appId: '1:294574323556:ios:64676accb7d45b26e72c71',
    messagingSenderId: '294574323556',
    projectId: 'tugas-individu-hermansawira',
    databaseURL: 'https://tugas-individu-hermansawira-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-individu-hermansawira.firebasestorage.app',
    iosBundleId: 'com.example.tugasMandiri',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkvb2INxXs_pcjeB0nLyXM-hAGC4-M7eE',
    appId: '1:294574323556:web:ef875616c30d26dee72c71',
    messagingSenderId: '294574323556',
    projectId: 'tugas-individu-hermansawira',
    authDomain: 'tugas-individu-hermansawira.firebaseapp.com',
    databaseURL: 'https://tugas-individu-hermansawira-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-individu-hermansawira.firebasestorage.app',
    measurementId: 'G-66RGSXP43R',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCnmq1YyICp_nktQ_e9Inp86UYT_-DyEik',
    appId: '1:294574323556:ios:64676accb7d45b26e72c71',
    messagingSenderId: '294574323556',
    projectId: 'tugas-individu-hermansawira',
    databaseURL: 'https://tugas-individu-hermansawira-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-individu-hermansawira.firebasestorage.app',
    iosBundleId: 'com.example.tugasMandiri',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAkvb2INxXs_pcjeB0nLyXM-hAGC4-M7eE',
    appId: '1:294574323556:web:9ae5fceed44f29d3e72c71',
    messagingSenderId: '294574323556',
    projectId: 'tugas-individu-hermansawira',
    authDomain: 'tugas-individu-hermansawira.firebaseapp.com',
    databaseURL: 'https://tugas-individu-hermansawira-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-individu-hermansawira.firebasestorage.app',
    measurementId: 'G-2JKTC87G8C',
  );

}