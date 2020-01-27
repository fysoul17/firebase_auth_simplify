# Firebase Authentication Simplify

A high-level framework of Firebase Auth package that wraps several lines of codes to one line in order to easily use sign-in function.

## Why/Who should use this

You may want to use [firebase_auth](https://pub.dev/packages/firebase_auth) package directly if you need specific customization on sign-in/out logic.      
However, although the most of usecases have almost the same signing-in and out codes, it is pain to write redundant codes everytime even if it is just a several lines of code. Especially, when you provide more than 2 sign-in methods. 

You will basically write some codes like below for **Each** of sign-in methods, and you want to manage it seperatly from the widget you use.

```dart
// Example of Google sign in (What you will do with original packages)

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

**This package has nothing fancy but just do the dirty things for you and what you will have is something like:**

```dart
import 'package:firebase_auth_simplify/firebase_auth_simplify.dart';

// Google
FirebaseAuthAPI.signInWith(GoogleSignInAPI());

// Facebook
FirebaseAuthAPI.signInWith(FacebookSignInAPI());

...
```

So if your priority is 'simplicity' and 'less code' for 3rd party integration, it is worth using this package.

## Who should consider NOT using this
Firstly, if your project only uses firebase provided sign-in methods, such as email or phone auth, it is better using [firebase_auth](https://pub.dev/packages/firebase_auth) package directly.

Secondly, as this package includes several 3rd party sign-ins, such as google, facebook and kakao, it contains related packages which you might not need it. For example, even though you only provide email and google sign-in methods to the customer, your project will still contain facebook or other sign-in packages which is not necessary in your case. If the issue matters to you, I recommend using your own way instead of implementing this package

## Currently supporting Sign-ins (X = supporting)
- [X] Email
- [X] Phone
- [X] Google
- [ ] Google Play Games (Need to wait for the [firebase_auth](https://pub.dev/packages/firebase_auth) to support this)
- [X] Facebook
- [X] Kakao
- [ ] Apple (Need to wait for the [firebase_auth](https://pub.dev/packages/firebase_auth) to support this)
- [ ] GameCenter (Need to wait for the [firebase_auth](https://pub.dev/packages/firebase_auth) to support this)
- [ ] Twitter
- [ ] Github

## Support
If the package was useful or saved your time, please do not hesitate to buy me a cup of coffee! ;)  
The more caffeine I get, the more useful projects I can make in the future. 

<a href="https://www.buymeacoffee.com/Oj17EcZ" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


## Getting Started

**NOTE: Only setup what you need. No need to configure all of followings**

### Firebase Auth Setup
This project uses firebase_auth package and is just a wrapper of it. So please make sure you follow setup instruction of [firebase_auth](https://pub.dev/packages/firebase_auth).

You basically need to [set google services](https://pub.dev/packages/firebase_auth) at Android build.gradle files, and then **you must [add App](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#6) at Firebase Console**.

> **NOTE**: If previous setting is not completed you will get an error like below.

> ```
> java.lang.IllegalStateException:
> Default FirebaseApp is not initialized in this process [package name].
> Make sure to call FirebaseApp.initializeApp(Context) first.
> ```

### Google sign in Setup
Import [google_sign_in](https://pub.dev/packages/google_sign_in) package and follow the instruction.

### Facebook sign in Setup

### Kakao sign in Setup
Import [flutter_kakao_login](https://pub.dev/packages/flutter_kakao_login) package and follow the instruction.

We also need a cloud function which creates custom token with kakao uid. 

```javascript
const admin = require("firebase-admin");
admin.initializeApp();

exports.createCustomToken = functions.https.onCall((data, context) => {
  // Grab uid.
  const uid = data.uid;

  return admin
    .auth()
    .createCustomToken(uid)
    .then(function(customToken) {
      // Send token back to client
      return { token: customToken, error: "" };
    })
    .catch(function(error) {
      console.log("Error creating custom token:", error);
      return { error: error };
    });
});
```

## Usage

### Simplest way
Simply initialize the class you want to sign in for, and call signIn() function.   
**NOTE: If you use it this way, you need to manage 3rd party sign-'out' logic yourself, because 'firebase_auth' package does not support the function yet. It only provides signOut() function for firebase provided auth such as email.**

```dart
// e-mail
FirebaseEmailAuthAPI(email: inputEmail, password: inputPassword).signUp();
FirebaseEmailAuthAPI(email: inputEmail, password: inputPassword).signIn();

// google
FirebaseGoogleAuthAPI().signIn();
// or
FirebaseGoogleAuthAPI(scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']).signIn();

```

### Using the wrapper
We provide FirebaseAuthProvider so that we can manage a sign-out function for you. 

```dart
FirebaseAuthProvider.instance.signInWith(FirebaseWhateverAuthAPI());

// Then you can sign-out anywhere. 
FirebaseAuthProvider.instance.signOut();
```
  
**NOTE: Good thing to use this way is it does not only sign out from Firestore, but also sign out from 3rd party provider which we can allow user to sign-in with another account to the same provider**


### Other useful packages you might be instrested
[Material design Speed Dial](https://pub.dev/packages/flutter_speed_dial_material_design)   
[Google Maps Place Picker](https://pub.dev/packages/google_maps_place_picker)

<a href="https://www.buymeacoffee.com/Oj17EcZ" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
