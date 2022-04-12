import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }


// Future<Map<String, String>> signUp(String email, String password) async{
//   print('************************in signup');
//   Future<void> future = (await FirebaseInit()
//       .db()
//       .collection('users')
//       .add({'password': password, 'favorites': null})) as Future<void>;
//   // return UserData(email, password, null);
//   return {'email': email, 'password': password};
// }

// Future<Map<String, String>> addUserDoc(String email, String password) async{
//   print('************************in signup');
//   Future<void> future = (await FirebaseInit()
//       .db()
//       .collection('users')
//       .add([])) as Future<void>;
//   // return UserData(email, password, null);
//   return {'email': email, 'password': password};
// }

// Future<Map<String, String?>> getUser(String email, String password) async {
//   String _email;
//   String _password;
//   print('************************in getUser');
//   try {
//     await FirebaseInit()
//         .db()
//         .collection('users')
//         .doc(email)
//         .get()
//         .then((DocumentSnapshot ds) async {
//       if (!ds.exists) {
//         print('************************in getUser newUser');
//         return await signUp(email, password);
//       }
//       else {
//         _email = email;
//         _password = ds["password"];
//         print('************************in getUser old user');
//         print('************************in getUser old user $email, $_email');
//         print('************************in getUser old user $password, $_password');
//         // getTypeName(dynamic obj) => obj.runtimeType;
//         print('************************STAM');
//         if (password != _password) {
//           print('************************password != _password');
//           //return null;
//           return {'email': null, 'password': null};
//         }
//         UserData? user = UserData(email, password, null);
//         print('************************ user ${user.email} ${user.password}');
//         return {'email': email, 'password': password};
//     }});
//     return {'email': null, 'password': null};
//   }catch(e){
//     print("%%%%%%%%%%%%%%%%%% ERROR $e");
//     // return null;
//     return {'email': null, 'password': null};
//   }
// }

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
      print("###################################222 ${_status}");
      return true;
      // Timer(Duration(seconds: 2), () {
      //     print("Yeah, this line is printed after 2 seconds");
      //     // _status = Status.Authenticated;
      //     // notifyListeners();
      //   });
      // Map<String,String?> m1 = await getUser(email, password);
      // print("***** ${m1['email']} ${m1['password']} *****");
      // UserData? user = UserData(m1['email'], m1['password'],null);
      // print("###### ${user.email} ${user.password} #######");
      // if (user.email != null && user.password != null) {
      //   ///not null == we found/created a user
      //   // await _auth.signInWithEmailAndPassword(email: email, password: password);
      //   print("###### GOOD LOGIN #######");
      //   showSnackBar(context: context, text: email + " " + password);
      //   _status = Status.Authenticated;
      //   notifyListeners();
      //   // return true;
      // }
      // else {
      //   _status = Status.Unauthenticated;
      //   print("###### BAD LOGIN #######");
      //   showSnackBar(context: context, text: "There was an error logging into the app");
      //   notifyListeners();
      //   // return true;
      //   // return false;
      // }
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
    print("###################################333 ${_status}");
    notifyListeners();
  }
}