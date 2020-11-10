import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthAPI {
  Future<UserCredential> signUp();
  Future<UserCredential> signIn();
  Future<void> signOut();
  Future<User> linkWith(User user);
  Future<void> unlinkFrom(User user);
}
