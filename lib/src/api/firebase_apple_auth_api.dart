import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_simplify/src/api/base_auth_api.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAppleAuthAPI implements BaseAuthAPI {
  FirebaseAppleAuthAPI({
    this.scopes,
    this.webAuthOptions,
  });

  final List<AppleIDAuthorizationScopes> scopes;
  final WebAuthenticationOptions webAuthOptions;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signIn() async {
    try {
      final authResult =
          await _firebaseAuth.signInWithCredential(await _getCredential());
      assert(authResult.user.uid == _firebaseAuth.currentUser.uid);

      // When sign in is done, update email info.
      await authResult.user.updateEmail(authResult.user.email);

      return authResult;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    try {
      final _scopes = scopes ??
          [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ];

      final nonce = _createNonce(32);
      final nativeAppleCred = Platform.isIOS
          ? await SignInWithApple.getAppleIDCredential(
              scopes: _scopes,
              nonce: sha256.convert(utf8.encode(nonce)).toString(),
            )
          : await SignInWithApple.getAppleIDCredential(
              scopes: _scopes,
              webAuthenticationOptions: webAuthOptions,
              nonce: sha256.convert(utf8.encode(nonce)).toString(),
            );

      final credential = OAuthCredential(
        providerId: "apple.com", // MUST be "apple.com"
        signInMethod: "oauth", // MUST be "oauth"
        accessToken: nativeAppleCred
            .identityToken, // propagate Apple ID token to BOTH accessToken and idToken parameters
        idToken: nativeAppleCred.identityToken,
        rawNonce: nonce,
      );

      return credential;
    } catch (e) {
      return Future.error(e);
    }
  }

  String _createNonce(int length) {
    final random = Random();
    final charCodes = List<int>.generate(length, (_) {
      int codeUnit;

      switch (random.nextInt(3)) {
        case 0:
          codeUnit = random.nextInt(10) + 48;
          break;
        case 1:
          codeUnit = random.nextInt(26) + 65;
          break;
        case 2:
          codeUnit = random.nextInt(26) + 97;
          break;
      }

      return codeUnit;
    });

    return String.fromCharCodes(charCodes);
  }

  /// Google API does not need sign up.
  @override
  Future<UserCredential> signUp() {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Google Signin does not need sign up.");
  }

  @override
  Future<void> signOut() {
    return Future.value();
  }

  @override
  Future<User> linkWith(User user) async {
    try {
      return (await user.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(User user) async {
    try {
      await user.unlink("apple.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
