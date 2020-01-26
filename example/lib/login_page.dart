import 'package:flutter/material.dart';
import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';
import 'package:flutter/services.dart';

import 'user_credential_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          _buildCredentialOptions(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      padding: EdgeInsets.only(bottom: 270),
      width: double.maxFinite,
      height: double.maxFinite,
      child: Image.asset(
        "asset/icon.png",
        fit: BoxFit.scaleDown,
      ),
    );
  }

  Widget _buildCredentialOptions(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: 300.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              _emailSignInButton(context),
              _phoneSignInField(context),
              _googleSignInButton(),
              _facebookSignInButton(),
              _kakaoSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailSignInButton(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Sign in with Email"),
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
                          hintText: "example@flutter.com",
                          labelText: "e-mail"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (text) {
                        UserCredentialProvider.of(context, listen: false).email = text;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "********",
                        labelText: "password",
                      ),
                      obscureText: true,
                      onChanged: (text) {
                        UserCredentialProvider.of(context, listen: false).password = text;
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  RaisedButton(
                    child: Text("Sign in"),
                    onPressed: () {
                      UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                      _performSignIn(api);
                    },
                  ),
                  RaisedButton(
                    child: Text("Create New Account"),
                    onPressed: () {
                      UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                      _createAccount(api);
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

  Widget _phoneSignInField(BuildContext context) {
    return Container();
  }

  Widget _googleSignInButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Sign in with Google"),
      onPressed: () {
        _performSignIn(FirebaseGoogleAuthAPI());
      },
    );
  }

  Widget _facebookSignInButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Sign in with Facebook"),
      onPressed: () {},
    );
  }

  Widget _kakaoSignInButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Sign in with Kakao"),
      onPressed: () {},
    );
  }

  _performSignIn(BaseAuthAPI api) async {
    try {
      await FirebaseAuthProvider.instance.signInWith(api);
    } on PlatformException catch (e) {
      print("platform exception: $e");
    } catch (e) {
      print("other exceptions: $e");
    }
  }

  _createAccount(BaseAuthAPI api) async {
    try {
      await FirebaseAuthProvider.instance.signUpWith(api);
    } on PlatformException catch (e) {
      print("platform exception: $e");
    } catch (e) {
      print("other exceptions: $e");
    }
  }
}
