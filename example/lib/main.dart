import 'package:flutter/material.dart';

import 'package:kakao_flutter_sdk/auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'landing_page.dart';
import 'user_credential_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoContext.clientId = "YOUR_NATIVE_APP_KEY";

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppPage(),
    );
  }
}

class AppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(">>> Build [App] Page");

    return Scaffold(
      appBar: AppBar(title: Text("Firebase Auth Example")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            return ChangeNotifierProvider(
              create: (_) => UserCredentialProvider(),
              child: LoginPage(),
            );
          } else {
            return ChangeNotifierProvider(
              create: (_) => UserCredentialProvider(),
              child: LandingPage(),
            );
          }
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        child: CircularProgressIndicator(),
        height: 25,
        width: 25,
      ),
    );
  }
}
