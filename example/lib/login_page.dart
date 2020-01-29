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
  bool _isLoading = false;

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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _isLoading
                  ? <Widget>[
                      _buildLoadingIndicator(),
                    ]
                  : <Widget>[
                      _emailSignInButton(context),
                      _phoneSignInField(context),
                      _googleSignInButton(),
                      _facebookSignInButton(),
                      _kakaoSignInButton(),
                    ]),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      child: CircularProgressIndicator(),
      height: 25,
      width: 25,
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
                        UserCredentialProvider.of(context, listen: false).email = text.trimRight();
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
                        UserCredentialProvider.of(context, listen: false).password = text.trimRight();
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  RaisedButton(
                    child: Text("Sign in"),
                    onPressed: () async {
                      UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                      bool succeed = await _performSignIn(api);
                      if (succeed) Navigator.of(context).pop();
                    },
                  ),
                  RaisedButton(
                    child: Text("Create New Account"),
                    onPressed: () async {
                      UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                      FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                      bool succeed = await _createAccount(api);
                      if (succeed) Navigator.of(context).pop();
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
      onPressed: () {
        _performSignIn(FirebaseFacebookAuthAPI());
      },
    );
  }

  Widget _kakaoSignInButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text("Sign in with Kakao"),
      onPressed: () {
        _performSignIn(FirebaseKakaoAuthAPI());
      },
    );
  }

  _performSignIn(BaseAuthAPI api) async {
    bool succeed = false;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuthProvider.instance.signInWith(api);
      succeed = true;
    } on PlatformException catch (e) {
      print("platform exception: $e");
      final snackBar = SnackBar(content: Text(e.message));
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("other exceptions: $e");
      final snackBar = SnackBar(content: Text(e.message));
      Scaffold.of(context).showSnackBar(snackBar);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    return succeed;
  }

  _createAccount(BaseAuthAPI api) async {
    bool succeed = false;

    try {
      await FirebaseAuthProvider.instance.signUpWith(api);
      succeed = true;
    } on PlatformException catch (e) {
      print("platform exception: $e");
    } catch (e) {
      print("other exceptions: $e");
    }

    return succeed;
  }
}
