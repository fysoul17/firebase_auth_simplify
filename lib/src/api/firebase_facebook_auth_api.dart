import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;

import 'base_auth_api.dart';

class FirebaseFacebookAuthAPI implements BaseAuthAPI {
  FirebaseFacebookAuthAPI({
    this.permissions = const [
      FacebookPermission.email,
      FacebookPermission.publicProfile
    ],
    this.useAndroidExpressLogin = true,
  });

  final List<FacebookPermission> permissions;
  final bool useAndroidExpressLogin;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FacebookLogin _facebookLogin = FacebookLogin();

  String? token;

  @override
  Future<UserCredential> signIn() async {
    try {
      final authResult =
          await _firebaseAuth.signInWithCredential(await _getCredential());
      assert(authResult.user!.uid == _firebaseAuth.currentUser!.uid);

      final url = Uri.https('graph.facebook.com', '/v2.12/me',
          {'fields': 'email', 'access_token': token});

      // When sign in is done, update email info.
      final graphResponse = await http.get(url);
      final profile = jsonDecode(graphResponse.body);

      if (profile['email'] == null) {
        throw PlatformException(
            code: "EMAIL_NOT_PROVIDED",
            message: "e-mail must be provided to use the app.");
      }

      await authResult.user!.updateEmail(profile['email']);

      return authResult;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    final FacebookLoginResult result = await _signInProvider();

    if (result.status == FacebookLoginStatus.cancel) {
      return Future.error(PlatformException(
          code: "FACEBOOK_CANCELLED_BY_USER",
          message: "Facebook sign-in is cancelled by user."));
    } else if (result.status == FacebookLoginStatus.error) {
      return Future.error(PlatformException(
          code: "FACEBOOK_SIGN_IN_FAILED",
          message: result.error!.developerMessage));
    }

    token = result.accessToken!.token;

    return FacebookAuthProvider.credential(token!);
  }

  Future<FacebookLoginResult> _signInProvider() async {
    if (useAndroidExpressLogin) {
      return await _facebookLogin.expressLogin();
    }

    return await _facebookLogin.logIn(permissions: permissions);
  }

  @override
  Future<void> signOut() {
    return _facebookLogin.logOut();
  }

  @override
  Future<User?> linkWith(User? user) async {
    try {
      return (await user!.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      _facebookLogin.logOut();
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
  Future<void> unlinkFrom(User? user) async {
    try {
      await user!.unlink("facebook.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
