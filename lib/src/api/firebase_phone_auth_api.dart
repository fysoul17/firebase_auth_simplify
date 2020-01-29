import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_auth_api.dart';

class FirebasePhoneAuthAPI implements BaseAuthAPI {
  FirebasePhoneAuthAPI({
    @required this.phoneNumber,
  });

  final String phoneNumber;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AuthResult> signUp() async {
    throw PlatformException(code: "UNSUPPORTED_FUNCTION", message: "Phone Signin does not need sign up.");
  }

  @override
  Future<AuthResult> signIn() async {
    print("sign in with $phoneNumber");
    try {
      return await _firebaseAuth.signInWithCredential(null);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) {}
}
