import 'package:example/user_credential_provider.dart';
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
    print(">>> Build [Landing] Page");
    return SingleChildScrollView(
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSignOutButton(),
          _displayUserInfo(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildFacebookLinkButton(),
              SizedBox(width: 10),
              _buildFacebookUnlinkButton(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildGoogleLinkButton(),
              SizedBox(width: 10),
              _buildGoogleUnlinkButton(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildKakaoLinkButton(),
              SizedBox(width: 10),
              _buildKakaoUnlinkButton(),
            ],
          ),
          Text("May take some time linking account for Kakao if the cloud server is on cold start"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPhoneLinkButton(),
              SizedBox(width: 10),
              _buildPhoneUnlinkButton(),
            ],
          ),
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

  Widget _buildFacebookUnlinkButton() {
    return RaisedButton(
      child: Text("Unlink with Facebook"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.unlinkCurrentUserFrom(FirebaseFacebookAuthAPI());
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

  Widget _buildGoogleUnlinkButton() {
    return RaisedButton(
      child: Text("Unlink with Google"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.unlinkCurrentUserFrom(FirebaseGoogleAuthAPI());
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

  Widget _buildKakaoUnlinkButton() {
    return RaisedButton(
      child: Text("Unlink with Kakao"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.unlinkCurrentUserFrom(FirebaseKakaoAuthAPI());
          setState(() {});
        } catch (e) {
          print(e);
        }
      },
    );
  }

  Widget _buildPhoneLinkButton() {
    final FirebasePhoneAuthAPI phoneAuthAPI = FirebasePhoneAuthAPI();

    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Link with Phone"),
      onPressed: () {
        showDialog(
          context: context,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          hintText: "+11 123-456-7890",
                          labelText: "Phone Number"),
                      keyboardType: TextInputType.phone,
                      onChanged: (text) {
                        UserCredentialProvider.of(context, listen: false).phoneNumber = text.trim();
                      },
                    ),
                  ),
                  RaisedButton(
                    child: Text("Send Code"),
                    onPressed: () async {
                      final UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      phoneAuthAPI.verifyNumber(provider.phoneNumber, codeSent: (String verificationId, [int forceResendingToken]) {
                        print("Code sent");
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "123456",
                        labelText: "Code",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        UserCredentialProvider.of(context, listen: false).code = text.trim();
                      },
                    ),
                  ),
                  RaisedButton(
                    child: Text("Link"),
                    onPressed: () async {
                      final UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      phoneAuthAPI.submitVerificationCode(provider.code);

                      FirebaseUser user;
                      bool succeed;
                      try {
                        user = await FirebaseAuthProvider.instance.linkCurrentUserWith(phoneAuthAPI);
                        succeed = user != null;
                      } catch (e) {
                        print(e);
                        succeed = false;
                      }

                      if (succeed) {
                        print("Succeed");
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneUnlinkButton() {
    return RaisedButton(
      child: Text("Unlink with Phone"),
      onPressed: () async {
        try {
          await FirebaseAuthProvider.instance.unlinkCurrentUserFrom(FirebasePhoneAuthAPI());
          setState(() {});
        } catch (e) {
          print(e);
        }
      },
    );
  }
}
