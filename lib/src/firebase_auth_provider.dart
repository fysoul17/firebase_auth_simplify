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

  Future<FirebaseUser> currentUser() {
    return _firebaseAuth.currentUser();
  }

  Future<Map<dynamic, dynamic>> getUserClaim() async {
    try {
      FirebaseUser user = await currentUser();
      final IdTokenResult idToken = await user?.getIdToken(refresh: true);
      return idToken?.claims;
    } catch (e) {
      return Future.error(e);
    }
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
      // Previously signed-in before re-launching the app. So there is no _primaryAuth set. Need to find out how it is signed-in in order to sign-out properly.
      if (_primaryAuth == null) {
        _primaryAuth = await getAuthFromClaims();
      }

      await _firebaseAuth.signOut();

      // If provider is firebase, we don't need to sign-out anymore.
      if (_primaryAuth == null || _primaryAuth is FirebaseEmailAuthAPI || _primaryAuth is FirebasePhoneAuthAPI) return;

      // If primary sign in provider is not firebase, we should do manually for them.
      await _primaryAuth.signOut();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<BaseAuthAPI> getAuthFromClaims() async {
    try {
      BaseAuthAPI api;
      var userClaims = await getUserClaim();
      final String providerId = userClaims['firebase']['sign_in_provider'];

      if (providerId == "google.com") {
        api = FirebaseGoogleAuthAPI();
      } else if (providerId == "facebook.com") {
        api = FirebaseFacebookAuthAPI();
      }
      // Custom providers (providerId == "custom")
      else {
        if (userClaims['provider'] == "kakaocorp.com") {
          api = FirebaseKakaoAuthAPI();
        } else {
          // TBA. (eg. Link, Apple, etc..)
          api = null;
        }
      }
      return api;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// This will link the provided auth with currently signed-in user's account.
  /// If there is no previously signed-in user, this will throw an exception.
  Future<FirebaseUser> linkCurrentUserWith(BaseAuthAPI api) async {
    try {
      FirebaseUser prevUser = await currentUser();
      return await api.linkWith(prevUser);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// This will unlink the provided auth with currently signed-in user's account.
  ///
  /// If there is no previously signed-in user or no linked auth, this will throw an exception.
  /// PlatformException(FirebaseException, User was not linked to an account with the given provider.)
  Future<void> unlinkCurrentUserFrom(BaseAuthAPI api) async {
    try {
      FirebaseUser prevUser = await currentUser();
      await api.unlinkFrom(prevUser);
    } catch (e) {
      throw Future.error(e);
    }
  }
}
