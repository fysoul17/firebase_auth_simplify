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
    print(">>> Build [Login] Page");
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
                      _phoneSignInButton(context),
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
    return ElevatedButton(
      child: Text("Sign in with Email"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
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
                    ElevatedButton(
                      child: Text("Sign in"),
                      onPressed: () async {
                        final UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                        final FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                        bool succeed = await _performSignIn(api);
                        if (succeed) Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text("Create New Account"),
                      onPressed: () async {
                        final UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                        final FirebaseEmailAuthAPI api = FirebaseEmailAuthAPI(email: provider.email, password: provider.password);
                        bool succeed = await _createAccount(api);
                        if (succeed) Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _phoneSignInButton(BuildContext context) {
    final FirebasePhoneAuthAPI phoneAuthAPI = FirebasePhoneAuthAPI();

    return ElevatedButton(
      child: Text("Sign in with Phone"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
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
                    ElevatedButton(
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
                    ElevatedButton(
                      child: Text("Sign in"),
                      onPressed: () async {
                        final UserCredentialProvider provider = UserCredentialProvider.of(context, listen: false);
                        phoneAuthAPI.submitVerificationCode(provider.code);
                        final result = await FirebaseAuthProvider.instance.signInWith(phoneAuthAPI);
                        bool succeed = result != null;
                        if (succeed) Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _googleSignInButton() {
    return ElevatedButton(
      child: Text("Sign in with Google"),
      onPressed: () {
        _performSignIn(FirebaseGoogleAuthAPI());
      },
    );
  }

  Widget _facebookSignInButton() {
    return ElevatedButton(
      child: Text("Sign in with Facebook"),
      onPressed: () {
        _performSignIn(FirebaseFacebookAuthAPI());
      },
    );
  }

  Widget _kakaoSignInButton() {
    return ElevatedButton(
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
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("other exceptions: $e");
      final snackBar = SnackBar(content: Text(e));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
