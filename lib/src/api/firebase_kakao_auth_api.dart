import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kakao_login/flutter_kakao_login.dart';
import 'base_auth_api.dart';

class FirebaseKakaoAuthAPI implements BaseAuthAPI {
  FirebaseKakaoAuthAPI();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const String providerId = 'kakaocorp.com';

  FlutterKakaoLogin _kakaoSignIn = FlutterKakaoLogin();

  @override
  Future<AuthResult> signIn() async {
    try {
      final KakaoLoginResult kakaoResult = await _kakaoSignIn.logIn();
      if (kakaoResult.errorMessage != null &&
          kakaoResult.errorMessage.isNotEmpty) {
        return Future.error(PlatformException(
            code: "KAKAO_SIGNIN_FAILED", message: kakaoResult.errorMessage));
      }

      final authResult = await _firebaseAuth.signInWithCustomToken(
          token: await _verifyToken(await _getAccessToken()));

      final FirebaseUser user = authResult.user;
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);

      // When sign in is done, update email info.
      if (kakaoResult.account.userEmail.isNotEmpty) {
        authResult.user.updateEmail(kakaoResult.account.userEmail);
      }

      return authResult;
    } catch (e) {
      if (e.toString().contains("already in use")) {
        return Future.error(PlatformException(
            code: "ERROR_EMAIL_ALREADY_IN_USE",
            message: "The email address is already in use by another account"));
      }
      return Future.error(e);
    }
  }

  Future<String> _getAccessToken() async {
    final KakaoAccessToken accessToken =
        await (_kakaoSignIn.currentAccessToken);
    if (accessToken == null) {
      return Future.error(PlatformException(
          code: "KAKAO_ACCESSTOKEN_ERROR",
          message: "Failed to get access token from Kakao"));
    } else {
      return accessToken.token;
    }
  }

  Future<String> _verifyToken(String kakaoToken) async {
    try {
      final HttpsCallable callable = CloudFunctions.instance
          .getHttpsCallable(functionName: 'verifyKakaoToken')
            ..timeout = const Duration(seconds: 30);

      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'token': kakaoToken,
        },
      );

      if (result.data['error'] != null) {
        return Future.error(result.data['error']);
      } else {
        return result.data['token'];
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Kakao API does not need sign up.
  @override
  Future<AuthResult> signUp() {
    return Future.error(PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Kakao Signin does not need sign up."));
  }

  @override
  Future<void> signOut() {
    _kakaoSignIn ??= FlutterKakaoLogin();
    return _kakaoSignIn.logOut();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) async {
    try {
      final KakaoLoginResult kakaoResult = await _kakaoSignIn.logIn();
      if (kakaoResult.errorMessage != null &&
          kakaoResult.errorMessage.isNotEmpty) {
        return Future.error(PlatformException(
            code: "KAKAO_SIGNIN_FAILED", message: kakaoResult.errorMessage));
      }

      var kakaoToken = await _getAccessToken();

      final HttpsCallable callable = CloudFunctions.instance
          .getHttpsCallable(functionName: 'linkWithKakao')
            ..timeout = const Duration(seconds: 30);

      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'token': kakaoToken,
        },
      );

      if (result.data['error'] != null) {
        return Future.error(result.data['error']);
      } else {
        FirebaseUser user = await _firebaseAuth.currentUser();
        // Update email info if possible.
        if (kakaoResult.account.userEmail.isNotEmpty) {
          await user.updateEmail(kakaoResult.account.userEmail);
        }
        return user;
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(FirebaseUser user) async {
    try {
      await user.unlinkFromProvider("kakaocorp.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
