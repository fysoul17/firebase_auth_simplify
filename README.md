# Firebase Authentication Simplify

A high-level framework of Firebase Auth package that wraps several lines of codes to one line in order to easily use sign-in and out function.

## Why/Who should use this

You may want to use [firebase_auth](https://pub.dev/packages/firebase_auth) pacakage directly if you need specific customization on sign-in/out logic.  
However, although the most of usecases have almost the same signing-in and out codes, it is pain to write redundant codes everytime even if it is just a several lines of code. 

You will basically write some codes like below for **Each** of sign-in methods, and you want to manage it seperatly from the widget you use.

```dart
// Example of Google sign in

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<FirebaseUser> _handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("signed in " + user.displayName);
  return user;
}

_handleSignIn()
    .then((FirebaseUser user) => print(user))
    .catchError((e) => print(e));

_handleSignOut() {
    ...
}
```

This package has nothing fancy but just do the dirty things for you and what you will have is something like:

```dart
import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';
```

and

```dart
GoogleSignInAPI api;
await api.signIn();


FacebookSignInAPI api;
await api.signIn();

api.signOut();

...
```

## Support
If the package was useful or saved your time, please do not hesitate to buy me a cup of coffee! ;)  
The more caffeine I get, the more useful projects I can make in the future. 

<a href="https://www.buymeacoffee.com/Oj17EcZ" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

### Other useful packages
[Material design Speed Dial](https://github.com/fysoul17/flutter_speed_dial_material_design)
[Google Maps Place Picker](https://github.com/fysoul17/google_maps_place_picker/edit/master/README.md)


## Getting Started

This project uses firebase_auth package and is just a wrapper of it. So please make sure you follow configuration instruction of [firebase_auth](https://pub.dev/packages/firebase_auth).

You basically need to [set google services](https://pub.dev/packages/firebase_auth) at Android build.gradle files, and then **you must [add App](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#6) at Firebase Console**.

> **NOTE**: If previous setting is not completed you will get an error like below.

> ```
> java.lang.IllegalStateException:
> Default FirebaseApp is not initialized in this process [package name].
> Make sure to call FirebaseApp.initializeApp(Context) first.
> ```
