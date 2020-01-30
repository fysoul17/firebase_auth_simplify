import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'base_auth_api.dart';

class FirebasePhoneAuthAPI implements BaseAuthAPI {
  FirebasePhoneAuthAPI();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthCredential _credential;
  String _verificationId;

  Future<void> verifyNumber(String phoneNumber,
      {bool signInOnAutoRetrieval = true,
      int timeoutSeconds = 30,
      PhoneCodeSent codeSent,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed}) async {
    assert(phoneNumber != null && phoneNumber.length > 1);

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: timeoutSeconds),
      codeSent: (String verificationId, [int forceResendingToken]) {
        _verificationId = verificationId;

        codeSent(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;

        codeAutoRetrievalTimeout(verificationId);
      },
      verificationCompleted: (AuthCredential phoneAuthCredential) {
        _credential = phoneAuthCredential;

        verificationCompleted(phoneAuthCredential);
        if (signInOnAutoRetrieval) {
          signIn();
        }
      },
      verificationFailed: (AuthException error) {
        print(error.code);
        print(error.message);

        verificationFailed(error);
      },
    );
  }

  AuthCredential submitVerificationCode(String code) {
    assert(_verificationId != null);
    assert(code != null && code.length == 6);

    _credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: code,
    );

    return _credential;
  }

  @override
  Future<AuthResult> signUp() async {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Phone Signin does not need sign up.");
  }

  @override
  Future<AuthResult> signIn() async {
    try {
      AuthResult result = await _firebaseAuth.signInWithCredential(_credential);
      final FirebaseUser user = result.user;
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);
      return result;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<FirebaseUser> linkWith(FirebaseUser user) async {
    try {
      return (await user.linkWithCredential(_credential)).user;
    } catch (e) {
      return Future.error(e);
    }
  }
}
