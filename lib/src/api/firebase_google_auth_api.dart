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
  Future<UserCredential> signIn() async {
    try {
      final authResult =
          await _firebaseAuth.signInWithCredential(await _getCredential());
      assert(authResult.user.uid == _firebaseAuth.currentUser.uid);

      // When sign in is done, update email info.
      await authResult.user.updateEmail(account.email);

      return authResult;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<AuthCredential> _getCredential() async {
    try {
      _googleSignIn =
          scopes == null ? GoogleSignIn() : GoogleSignIn(scopes: scopes);

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
      return GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
    } catch (e) {
      return Future.error(e);
    }
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
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn.signOut();
  }

  @override
  Future<User> linkWith(User user) async {
    try {
      /// NOTE: As mentioned above in _getCredential function, we cannot catch exception here. Need to wait for google_sign package to solve this issue (or dart team).
      ///       This only happens in Debug mode.
      return (await user.linkWithCredential(await _getCredential())).user;
    } catch (e) {
      if (_googleSignIn != null) _googleSignIn.signOut();
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(User user) async {
    try {
      await user.unlink("google.com");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
