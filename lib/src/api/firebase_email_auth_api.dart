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
  Future<AuthResult> signUp() {
    print("sign up with $email and $password");
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<AuthResult> signIn() {
    print("sign in with $email and $password");
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) {
    throw PlatformException(code: "UNSUPPORTED_FUNCTION_EXCEPTION", message: "e-mail sign-in does not support linking");
  }
}
