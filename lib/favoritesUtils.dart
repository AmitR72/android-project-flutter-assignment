import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_state.dart';
import 'cloud_firestore.dart';


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
    print("****** firstTimeSync start");
    await FirebaseInit()
        .db()
        .collection('users')
        .doc(email)
        .set({'favorites': []});
    print("****** firstTimeSync end");
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
    if (email != "") {
      print("****** updateFromCloud 2 $email");
      if (authUser.isAuthenticated) {
        print("****** updateFromCloud auth true");
        try {
          await FirebaseInit()
              .db()
              .collection('users')
              .doc(email)
              .get()
              .then((DocumentSnapshot ds) {
            if (!ds.exists) {
              print("****** firstTimeSync start");
              firstTimeSync(email);
              print("****** firstTimeSync end");
              updateToCloud(authUser);
              print("****** updateToCloud end");
            } else {
              print("****** IN ELSE");

              ///combine favorites from cloud(db) and local
              List<dynamic> _dbFavorites = ds["favorites"];
              Set<WordPair> _newSet = Set();
              if (_dbFavorites.isNotEmpty) {
                for (int i = 0; i < _dbFavorites.length; i++) {
                  dynamic _first = _dbFavorites[i]['first'];
                  dynamic _second = _dbFavorites[i]['second'];
                  WordPair pair = WordPair(_first, _second);
                  _newSet.add(pair);
                }
                final unionSet = _newSet.union(_favorties);
                _favorties = unionSet;
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
    print("##### updateToCloudAndDeleteLocal 1");
    String email = authUser.user?.email ?? "";
    if (email != "") {
      if (authUser.isAuthenticated) {
        print("##### updateToCloudAndDeleteLocal 2");
        try {
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
              userFavorites.removeFromFavorites(pair);
              userFavorites.updateToCloud(authUser);
              print("@@@@@@@@@@@@@@@@@@@@@@@ POP TRUE");
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
