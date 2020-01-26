import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';
import 'package:firebase_auth_simplify/src/api/base_auth_api.dart';

class FirebaseAuthProvider {
  /// Private constructor
  FirebaseAuthProvider._();

  /// Provides an instance of this class
  static final FirebaseAuthProvider instance = FirebaseAuthProvider._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<FirebaseUser> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged;

  Future<FirebaseUser> currentUser() async {
    return await _firebaseAuth.currentUser();
  }

  BaseAuthAPI _primaryAuth;
  BaseAuthAPI get primaryAuth => _primaryAuth;

  Future<AuthResult> signUpWith(BaseAuthAPI api) async {
    _primaryAuth = api;

    return api.signUp();
  }

  Future<AuthResult> signInWith(BaseAuthAPI api) async {
    _primaryAuth = api;

    return api.signIn();
  }

  Future<void> signOut() async {
    try {
      FirebaseUser user = await currentUser();
      if (_primaryAuth == null) {
        for (UserInfo userInfo in user.providerData) {
          print(userInfo.providerId);

          if (userInfo.providerId == "facebook.com") {
            //
          } else if (userInfo.providerId == "google.com") {
            _primaryAuth = FirebaseGoogleAuthAPI();
          }
        }
      }

      await _firebaseAuth.signOut();

      if (_primaryAuth is FirebaseEmailAuthAPI) return;

      // If primary sign in provider is not firebase, we should do manually for them.
      await _primaryAuth.signOut();
    } catch (e) {
      return Future.error(e);
    }
  }
}
