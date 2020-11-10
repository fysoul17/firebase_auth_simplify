import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

import 'base_auth_api.dart';

class FirebaseFacebookAuthAPI implements BaseAuthAPI {
  FirebaseFacebookAuthAPI({
    this.webViewOnly = false,
  });

  final bool webViewOnly;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FacebookLogin _facebookLogin = FacebookLogin();

  String token;

  @override
  Future<UserCredential> signIn() async {
    try {
      final authResult =
          await _firebaseAuth.signInWithCredential(await _getCredential());
      assert(authResult.user.uid == _firebaseAuth.currentUser.uid);

      // When sign in is done, update email info.
      final graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=email&access_token=$token');
      final profile = jsonDecode(graphResponse.body);

      if (profile['email'] == null) {
        throw PlatformException(
            code: "EMAIL_NOT_PROVIDED",
            message: "e-mail must be provided to use the app.");
      }

      authResult.user.updateEmail(profile['email']);

      return authResult;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    final FacebookLoginResult result = await _signInProvider();

    if (result.status == FacebookLoginStatus.cancelledByUser) {
      return Future.error(PlatformException(
          code: "FACEBOOK_CANCELLED_BY_USER",
          message: "Facebook sign-in is cancelled by user."));
    } else if (result.status == FacebookLoginStatus.error) {
      return Future.error(PlatformException(
          code: "FACEBOOK_SIGN_IN_FAILED", message: result.errorMessage));
    }

    token = result.accessToken.token;

    return FacebookAuthProvider.credential(token);
  }

  Future<FacebookLoginResult> _signInProvider() async {
    if (webViewOnly) {
      _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    }

    return await _facebookLogin.logIn(['email']);
  }

  @override
  Future<void> signOut() {
    _facebookLogin ??= FacebookLogin();
    return _facebookLogin.logOut();
  }

  @override
  Future<User> linkWith(User user) async {
    try {
      return (await user.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      if (_facebookLogin != null) _facebookLogin.logOut();
      return Future.error(e);
    }
  }

  /// Facebook API does not need sign up.
  @override
  Future<UserCredential> signUp() {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Facebook Signin does not need sign up.");
  }

  @override
  Future<void> unlinkFrom(User user) async {
    try {
      await user.unlink("facebook.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
