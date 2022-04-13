import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthUser extends ChangeNotifier {
  FirebaseAuth _auth;
  //UserData? _user;
  User? _user;
  Status _status = Status.Unauthenticated;

  AuthUser.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;
  //UserData? get user => _user;
  User? get user => _user;
  bool get isAuthenticated => status == Status.Authenticated;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(BuildContext context, String email, String password) async {
    try {
      _status = Status.Authenticating;
      print("###################################${_status}");
      notifyListeners();
      // Timer(Duration(seconds: 1), () async {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      // });
      print("################################### 2 ${_status}");
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void signOut(BuildContext context) async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    showSnackBar(context: context, text: "Successfully logged out");
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    print("################################### 3 ${_status}");
    notifyListeners();
  }
}