import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_state.dart';
import 'cloud_firestore.dart';

// List<WordPair> favoritesSuggestions = [];

class UserFavorites extends ChangeNotifier{
  Set<WordPair> _favorties;

  UserFavorites() : _favorties = {};
  Set<WordPair> get favorties => _favorties;

  void addToFavorites(WordPair pair) {
    _favorties.add(pair);
    notifyListeners();
  }

  void removeFromFavorites(WordPair pair) {
    _favorties.remove(pair);
    notifyListeners();
  }

  Future<void> firstTimeSync(String email) async {
    print("****** firstTimeSync");
    await FirebaseInit()
        .db()
        .collection('users')
        .doc(email)
        .set({'favorites': []});
    print("****** firstTimeSync END");
  }

  Future<void> updateToCloud(AuthUser authUser) async {
    print("##### updateToCloud");
    String email = authUser.user?.email ?? "";
    if (email != "") {
      if (authUser.isAuthenticated) {
        try {
          List<Map<String,String>> _toDb = favorties.map((e) =>
          {'first': e.first, 'second': e.second}).toList();
          await FirebaseInit()
              .db()
              .collection('users')
              .doc(email)
              .set(favorties.isEmpty ?
                  {'favorites': []} :
                  {'favorites': _toDb});
        } catch (e) {
          print("##### having a problem updateToCloud");
        }
      }
    }
  }

  Future<void> updateFromCloud(AuthUser authUser) async {
    print("****** updateFromCloud");
    String email = authUser.user?.email ?? "";
    print("****** updateFromCloud 2.0 $email");
    if (email != "") {
      print("****** updateFromCloud 2 $email");
      if (authUser.isAuthenticated) {
        print("****** updateFromCloud 3");
        try {
          await FirebaseInit()
              .db()
              .collection('users')
              .doc(email)
              .get()
              .then((DocumentSnapshot ds) {
            if (!ds.exists) {
              print("****** 000 firstTimeSync");
              firstTimeSync(email);
              print("****** 111 firstTimeSync");
              updateToCloud(authUser);
              print("****** 222 firstTimeSync updateToCloud");
            } else {
              print("****** IN ELSE");

              ///combine favorites from cloud(db) and local
              // _dbFavorites = ds["favorites"];
              List<dynamic> _dbFavorites = ds["favorites"];
              print("****** 2222");
              Set<WordPair> _newSet = Set();
              if (_dbFavorites.isNotEmpty) {
                for (int i = 0; i < _dbFavorites.length; i++) {
                  dynamic _first = _dbFavorites[i]['first'];
                  dynamic _second = _dbFavorites[i]['second'];
                  WordPair pair = WordPair(_first, _second);
                  _newSet.add(pair);
                }
                // Set<WordPair> updatedFavorites = _dbFavorites as Set<WordPair>;
                print("****** 3333");
                // final unionSet = updatedFavorites.union(_favorties);
                final unionSet = _newSet.union(_favorties);
                print("****** 4444");
                _favorties = unionSet;
                print("****** 5555");
                notifyListeners();
              }
            }
          });
        } catch (e) {
          print("****** having a problem");
        }
      }
    }
  }

  Future<void> updateToCloudAndDeleteLocal(AuthUser authUser) async {
    print("##### updateToCloudAndDeleteLocal 1111111111111111");
    String email = authUser.user?.email ?? "";
    if (email != "") {
      if (authUser.isAuthenticated) {
        print("##### updateToCloudAndDeleteLocal 22222222222222222");
        try {
              // FirebaseInit()
              // .db()
              // .collection('users')
              // .doc(email)
              // .set({'favorites': favorties});
          updateToCloud(authUser);
          _favorties = {};
          notifyListeners();
        } catch (e) {
          print("##### having a problem");
        }
      }
    }
  }
}

Future<Future<bool?>> showAlertDialogDel(BuildContext context, WordPair pair,
    UserFavorites userFavorites, AuthUser authUser) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // user doesn't must to tap a button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Suggestion'),
        content: Text ('Are you sure you want to delete ${pair.asPascalCase}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              print("@@@@@@@@@@@@@@@@@@@@@@@2 POP TRUE BEFORE");
              userFavorites.removeFromFavorites(pair);
              print("@@@@@@@@@@@@@@@@@@@@@@@2 POP TRUE 2nd");
              userFavorites.updateToCloud(authUser);
              print("@@@@@@@@@@@@@@@@@@@@@@@2 POP TRUE");
              Navigator.pop(context, true);
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      );
    },
  );
}

Widget favoriteScaffold(List<Widget> divided, UserFavorites userFavorites,
    AuthUser authUser){
  return Scaffold(
    appBar: AppBar(
      title: const Text('Saved Suggestions'),
    ),
    // body: ListView(children: divided),
    body: ListView.builder(
      itemCount: divided.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
            background: Container(
              alignment: Alignment.centerLeft,
              color: Colors.deepPurple,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Icon( // <-- Icon
                      Icons.delete,
                      color: Colors.white
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Delete Suggestion',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ), // <-- Text
                ],
              ),
            ),
            key: ValueKey<Widget>(divided[index]),
            confirmDismiss: (DismissDirection direction) async {
              // return await showSnackBarDel(context);
              return await showAlertDialogDel(context,
              userFavorites.favorties.elementAt(index),
              userFavorites, authUser);
            },
            child: divided[index]);
      },
    ),
  );
}




// Future<Map<String, String?>> getFavorite(String email, String password) async {
//   String _email;
//   String _password;
//   try {
//     await FirebaseInit()
//         .db()
//         .collection('users')
//         .doc(email)
//         .get()
//         .then((DocumentSnapshot ds) async {
//       if (!ds.exists) {
//         return await signUp(email, password);
//       }
//       else {
//         _email = email;
//         _password = ds["password"];
//         if (password != _password) {
//           //return null;
//         }
//         UserData? user = UserData(email, password, null);
//         return {'email': email, 'password': password};
//       }});
//     return {'email': null, 'password': null};
//   }catch(e){
//     // return null;
//     return {'email': null, 'password': null};
//   }
// }
