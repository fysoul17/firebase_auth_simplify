import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart' as kakao;
import 'base_auth_api.dart';

class FirebaseKakaoAuthAPI implements BaseAuthAPI {
  FirebaseKakaoAuthAPI();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const String providerId = 'kakaocorp.com';

  @override
  Future<UserCredential> signIn() async {
    try {
      final String token = await _retrieveToken();
      final authResult =
          await _firebaseAuth.signInWithCustomToken(await _verifyToken(token));

      final User firebaseUser = authResult.user;
      assert(firebaseUser.uid == _firebaseAuth.currentUser.uid);

      if (authResult.user.email.isEmpty) {
        // When sign in is done, update email info.
        kakao.User kakaoUser = await kakao.UserApi.instance.me();
        if (kakaoUser.kakaoAccount.email.isNotEmpty) {
          await authResult.user.updateEmail(kakaoUser.kakaoAccount.email);
        }
      }

      return authResult;
    } on KakaoAuthException catch (e) {
      return Future.error(e);
    } on KakaoClientException catch (e) {
      return Future.error(e);
    } catch (e) {
      if (e.toString().contains("already in use")) {
        return Future.error(PlatformException(
            code: "ERROR_EMAIL_ALREADY_IN_USE",
            message: "The email address is already in use by another account"));
      }
      return Future.error(e);
    }
  }

  Future<String> _retrieveToken() async {
    final installed = await isKakaoTalkInstalled();
    final authCode = installed
        ? await AuthCodeClient.instance.requestWithTalk()
        : await AuthCodeClient.instance.request();
    AccessTokenResponse token =
        await AuthApi.instance.issueAccessToken(authCode);

    await AccessTokenStore.instance.toStore(
        token); // Store access token in AccessTokenStore for future API requests.
    return token.accessToken;
  }

  Future<String> _verifyToken(String kakaoToken) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('verifyKakaoToken');

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
  Future<UserCredential> signUp() {
    return Future.error(PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Kakao Signin does not need sign up."));
  }

  @override
  Future<void> signOut() {
    AccessTokenStore.instance.clear();
    return Future.value("");
  }

  @override
  Future<User> linkWith(User user) async {
    try {
      final token = await _retrieveToken();

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('linkWithKakao');

      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'token': token,
        },
      );

      if (result.data['error'] != null) {
        return Future.error(result.data['error']);
      } else {
        return user;
      }
    } on KakaoAuthException catch (e) {
      return Future.error(e);
    } on KakaoClientException catch (e) {
      return Future.error(e);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(User user) async {
    try {
      await user.unlink("kakaocorp.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
