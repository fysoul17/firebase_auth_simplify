# Firebase Authentication Simplify

A high-level framework of Firebase Auth package that wraps several lines of codes to one line in order to easily use sign-in and out function.

## Getting Started

This project uses firebase_auth package and is just a wrapper of it. So please make sure you follow configuration instruction of [firebase_auth](https://pub.dev/packages/firebase_auth).

You basically need to [set google services](https://pub.dev/packages/firebase_auth) at Android build.gradle files, and then **you must [add App](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#6) at Firebase Console**.

> **NOTE**: If previous setting is not completed you will get an error like below.

> ```
> java.lang.IllegalStateException:
> Default FirebaseApp is not initialized in this process [package name].
> Make sure to call FirebaseApp.initializeApp(Context) first.
> ```
