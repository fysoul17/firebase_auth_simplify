import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_auth_api.dart';

class FirebaseEmailAuthAPI implements BaseAuthAPI {
  FirebaseEmailAuthAPI({
    @required this.email,
    @required this.password,
  });

  final String email;
  final String password;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signUp() async {
    print("sign up with $email and $password");
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<UserCredential> signIn() async {
    print("sign in with $email and $password");
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      assert(authResult.user.uid == _firebaseAuth.currentUser.uid);

      return authResult;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<User> linkWith(User user) {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "e-mail sign-in does not support linking and unlinking");
  }

  @override
  Future<void> unlinkFrom(User user) async {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "e-mail sign-in does not support linking and unlinking");
  }
}
