import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_simplify/src/api/base_auth_api.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseGoogleAuthAPI implements BaseAuthAPI {
  FirebaseGoogleAuthAPI({this.scopes});

  final List<String> scopes;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount account;

  @override
  Future<AuthResult> signIn() async {
    try {
      final authResult = await _firebaseAuth.signInWithCredential(await _getCredential());
      // When sign in is done, update email info.
      authResult.user.updateEmail(account.email);

      return authResult;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    try {
      _googleSignIn = scopes == null ? GoogleSignIn() : GoogleSignIn(scopes: scopes);

      // NOTE: signIn() does the work automatically.
      // GoogleSignInAccount account = await _googleSignIn.signInSilently();

      // NOTE: In debug mode, it will throw an exception when user cancel the sign in process, even if it just have to give us 'null'.
      //       It is a VM debugger issue which doesn't correctly detects it.
      //       Do not bother for having unhandled exception in debug mode. It will work on release mode. Just check if it is null for user canceled action.
      //
      //       More info: https://github.com/flutter/flutter/issues/26705#issuecomment-507791687
      account = await _googleSignIn.signIn();

      // User canceld.
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return GoogleAuthProvider.getCredential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
    } catch (e) {
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
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn.signOut();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) async {
    try {
      /// NOTE: As mentioned above in _getCredential function, we cannot catch exception here. Need to wait for google_sign package to solve this issue (or dart team).
      ///       This only happens in Debug mode.
      return (await user.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      if (_googleSignIn != null) _googleSignIn.signOut();
      return Future.error(e);
    }
  }
}
