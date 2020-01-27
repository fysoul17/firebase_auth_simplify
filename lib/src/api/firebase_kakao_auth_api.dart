import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kakao_login/flutter_kakao_login.dart';
import 'base_auth_api.dart';

class FirebaseKakaoAuthAPI implements BaseAuthAPI {
  FirebaseKakaoAuthAPI();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FlutterKakaoLogin _kakaoSignIn = FlutterKakaoLogin();

  @override
  Future<AuthResult> signIn() async {
    final KakaoLoginResult kakaoResult = await _kakaoSignIn.logIn();

    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'createCustomToken')..timeout = const Duration(seconds: 30);

      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'uid': kakaoResult.account.userID,
        },
      );

      final authResult = await _firebaseAuth.signInWithCustomToken(token: result.data['token']);

      // When sign in is done, update email info.
      if (kakaoResult.account.userEmail.isNotEmpty) {
        authResult.user.updateEmail(kakaoResult.account.userEmail);
      }

      return authResult;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  /// Google API does not need sign up.
  @override
  Future<AuthResult> signUp() {
    throw PlatformException(code: "UNSUPPORTED_FUNCTION_EXCEPTION", message: "Google Signin does not need sign up.");
  }

  @override
  Future<void> signOut() {
    return _kakaoSignIn.logOut();
  }
}
