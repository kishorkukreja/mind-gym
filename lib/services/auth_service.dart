import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class GoogleAuthProfile {
  const GoogleAuthProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}

class GoogleAuthException implements Exception {
  GoogleAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class GoogleAuthService {
  Future<GoogleAuthProfile?> signIn();
  Future<void> signOut();
}

class FirebaseGoogleAuthService implements GoogleAuthService {
  FirebaseGoogleAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  firebase_auth.FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  Future<firebase_auth.FirebaseAuth> get _auth async {
    await _ensureFirebaseInitialized();
    return _firebaseAuth ??= firebase_auth.FirebaseAuth.instance;
  }

  @override
  Future<GoogleAuthProfile?> signIn() async {
    try {
      final credential = kIsWeb
          ? await _signInWithGooglePopup()
          : await _signInWithGoogleCredential();

      if (credential == null) return null;

      final user = credential.user;
      if (user == null) {
        throw GoogleAuthException('Google sign-in did not return a Firebase user.');
      }

      return GoogleAuthProfile(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } on GoogleAuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw GoogleAuthException(_firebaseMessage(error));
    } catch (_) {
      throw GoogleAuthException('Google sign-in failed. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureFirebaseInitialized();
    await (_firebaseAuth ?? firebase_auth.FirebaseAuth.instance).signOut();
    if (!kIsWeb) {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    }
  }

  Future<firebase_auth.UserCredential?> _signInWithGoogleCredential() async {
    await _ensureGoogleSignInInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw GoogleAuthException(
        'Google sign-in is not available on this platform in this build.',
      );
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw GoogleAuthException('Google sign-in did not return an ID token.');
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );
    return (await _auth).signInWithCredential(credential);
  }

  Future<firebase_auth.UserCredential?> _signInWithGooglePopup() async {
    final provider = firebase_auth.GoogleAuthProvider();
    return (await _auth).signInWithPopup(provider);
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  String _firebaseMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';
      case 'network-request-failed':
        return 'Google sign-in needs a network connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return error.message ?? 'Google sign-in failed. Please try again.';
    }
  }
}
