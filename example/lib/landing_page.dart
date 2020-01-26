import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Text("Landing page"),
        _buildSignOutButton(),
      ],
    ));
  }

  Widget _buildSignOutButton() {
    return RaisedButton(
      child: Text("Log out"),
      onPressed: () {
        FirebaseAuthProvider.instance.signOut();
      },
    );
  }
}
