import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'base_auth_api.dart';

class FirebasePhoneAuthAPI implements BaseAuthAPI {
  FirebasePhoneAuthAPI();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthCredential? _credential;
  String? _verificationId;

  Future<void> verifyNumber(String phoneNumber,
      {bool signInOnAutoRetrieval = true,
      int timeoutSeconds = 30,
      PhoneCodeSent? codeSent,
      PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout,
      PhoneVerificationCompleted? verificationCompleted,
      PhoneVerificationFailed? verificationFailed}) async {
    assert(phoneNumber != null && phoneNumber.length > 1);

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: timeoutSeconds),
      codeSent: (String verificationId, [int? forceResendingToken]) {
        _verificationId = verificationId;

        codeSent!(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;

        codeAutoRetrievalTimeout!(verificationId);
      },
      verificationCompleted: (AuthCredential phoneAuthCredential) {
        _credential = phoneAuthCredential;

        verificationCompleted!(phoneAuthCredential as PhoneAuthCredential);
        if (signInOnAutoRetrieval) {
          signIn();
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        print(error.code);
        print(error.message);

        verificationFailed!(error);
      },
    );
  }

  AuthCredential? submitVerificationCode(String code) {
    assert(_verificationId != null);
    assert(code != null && code.length == 6);

    _credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );

    return _credential;
  }

  @override
  Future<UserCredential> signUp() async {
    throw PlatformException(
        code: "UNSUPPORTED_FUNCTION",
        message: "Phone Signin does not need sign up.");
  }

  @override
  Future<UserCredential> signIn() async {
    try {
      UserCredential result =
          await _firebaseAuth.signInWithCredential(_credential!);
      assert(result.user!.uid == _firebaseAuth.currentUser!.uid);
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
  Future<User?> linkWith(User? user) async {
    try {
      return (await user!.linkWithCredential(_credential!)).user;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> unlinkFrom(User? user) async {
    try {
      await user!.unlink("phone");
    } catch (e) {
      throw Future.error(e);
    }
  }
}
