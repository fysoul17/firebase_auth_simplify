import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSignOutButton(),
          _displayUserInfo(),
          _buildFacebookLinkButton(),
          _buildGoogleLinkButton(),
          _buildKakaoLinkButton(),
        ],
      )),
    );
  }

  Widget _buildSignOutButton() {
    return RaisedButton(
      child: Text("Log out"),
      onPressed: () {
        FirebaseAuthProvider.instance.signOut();
      },
    );
  }

  Widget _displayUserInfo() {
    return FutureBuilder<Map<dynamic, dynamic>>(
      future: FirebaseAuthProvider.instance.getUserClaim(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Fetching user info");
        } else {
          if (snapshot.hasData) {
            return Text(snapshot.data.toString());
          } else {
            return Text("Could not fetch user info");
          }
        }
      },
    );
  }

  Widget _buildFacebookLinkButton() {
    return RaisedButton(
      child: Text("Link with Facebook"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.linkCurrentUserWith(FirebaseFacebookAuthAPI());
          setState(() {});
        } catch (e) {
          print(e);
        }
      },
    );
  }

  Widget _buildGoogleLinkButton() {
    return RaisedButton(
      child: Text("Link with Google"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.linkCurrentUserWith(FirebaseGoogleAuthAPI());
          setState(() {});
        } catch (e) {
          print(e);
        }
      },
    );
  }

  Widget _buildKakaoLinkButton() {
    return RaisedButton(
      child: Text("Link with Kakao"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.linkCurrentUserWith(FirebaseKakaoAuthAPI());
          setState(() {});
        } catch (e) {
          print(e);
        }
      },
    );
  }
}
