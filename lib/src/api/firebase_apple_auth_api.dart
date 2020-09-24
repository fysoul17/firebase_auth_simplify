import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_simplify/src/api/base_auth_api.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

class FirebaseAppleAuthAPI implements BaseAuthAPI {
  FirebaseAppleAuthAPI({this.scopes});

  final List<Scope> scopes;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthorizationResult _appleSignIn;

  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();

  @override
  Future<AuthResult> signIn() async {
    try {
      final authResult =
          await _firebaseAuth.signInWithCredential(await _getCredential());
      final FirebaseUser user = authResult.user;
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);

      // When sign in is done, update email info.
      authResult.user.updateEmail(_appleSignIn.credential.email);

      return authResult;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    try {
      if (await appleSignInAvailable == false) {
        throw PlatformException(
            code: "APPLE_SIGN_IN_NOT_AVAILABLE",
            message:
                "Apple sign in is not supported on this device. Is it iOS device? Is the OS higher than iOS 13?");
      }

      _appleSignIn = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: scopes ?? [Scope.email, Scope.fullName])
      ]);

      if (_appleSignIn.error != null) {
        throw PlatformException(
            code: "APPLE_SIGN_IN_REQUEST_FAILED",
            message: _appleSignIn.error.toString());
      }

      if (_appleSignIn.status == AuthorizationStatus.cancelled) {
        throw PlatformException(
            code: "APPLE_SIGN_IN_CANCELLED",
            message: "Apple sign in cancelled by user.");
      }

      final AuthCredential credential =
          OAuthProvider(providerId: 'apple.com').getCredential(
        accessToken:
            String.fromCharCodes(_appleSignIn.credential.authorizationCode),
        idToken: String.fromCharCodes(_appleSignIn.credential.identityToken),
      );

      return credential;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Google API does not need sign up.
  @override
  Future<AuthResult> signUp() {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Google Signin does not need sign up.");
  }

  @override
  Future<void> signOut() {
    return Future.value();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) async {
    try {
      return (await user.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(FirebaseUser user) async {
    try {
      await user.unlinkFromProvider("apple.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
