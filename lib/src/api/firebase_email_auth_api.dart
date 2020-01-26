import 'package:firebase_auth/firebase_auth.dart';
import 'base_auth_api.dart';

class FirebaseEmailAuthAPI implements BaseAuthAPI {
  FirebaseEmailAuthAPI({this.email, this.password});

  final String email;
  final String password;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AuthResult> signUp() {
    print("sign up with $email and $password");
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<AuthResult> signIn() {
    print("sign in with $email and $password");
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
