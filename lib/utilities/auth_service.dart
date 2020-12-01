import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.authStateChanges();
  }

  User get getUser => _auth.currentUser;

  // wrappinhg the firebase calls
  void logout() async {
    print("loging out");
    await _auth.signOut();
  }

  // wrappinhg the firebase calls
  void register(String email, String password, String pseudo) async {
    try {
      print("registering");
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      var user = _auth.currentUser;
      await user
          .updateProfile(displayName: pseudo)
          .then((value) => print("registered"));
    } catch (e) {
      if (e.code == 'weak-password') {
        print('The password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else
        print(e);
    }
  }

  // wrappinhg the firebase calls
  void loginUser(String email, String password) async {
    print("loging in");
    try {
      if (email.isNotEmpty && password.isNotEmpty)
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
    } on PlatformException catch (err) {
      print('platform exception' + err.code);
      // Handle err
    } catch (err) {
      // other types of Exceptions
    }
  }
}
