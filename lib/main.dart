import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'favoritesUtils.dart';
import 'auth_state.dart';


void main() {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthUser.instance()),
      ChangeNotifierProvider(create: (context) => UserFavorites())
    ], child: App()),
  );
}


class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      }
      return const Center(child: CircularProgressIndicator());
        },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
        // primaryColor: Colors.deepPurple,
        // appBarTheme: const AppBarTheme(
          // backgroundColor: Colors.white,
          // foregroundColor: Colors.black,
        // ),
        /// added this by myself to give it a personal touch (:
        splashColor: Colors.deepPurple,

        /// added this by myself to give it a personal touch (:
        pageTransitionsTheme: const PageTransitionsTheme(

            /// added this by myself to give it a personal touch (:
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder()
            }),
      ),
      home: const RandomWords(),
    );
  }
}


class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  // final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildRow(WordPair pair, AuthUser authUser) {
    // final alreadySaved = _saved.contains(pair);
    return Consumer<UserFavorites>(builder: (context, userFavorites, child) {
      final alreadySaved = userFavorites.favorties.contains(pair);
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.star : Icons.star_border,
          color: alreadySaved ? Colors.deepPurple : null,
          semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          // setState(() {
            if (alreadySaved) {
              //_saved.remove(pair);
              userFavorites.removeFromFavorites(pair);
            } else {
              // _saved.add(pair);
              userFavorites.addToFavorites(pair);
            }
          // });
          userFavorites.updateToCloud(authUser);
        },
      );
    });
  }

  Widget _buildSuggestions(AuthUser authUser) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return const Divider();
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final index = i ~/ 2;
        // If you've reached the end of the available word pairings...
        if (index >= _suggestions.length) {
          // ...then generate 10 more and add them to the suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index], authUser);
      },
    );
  }



  void _pushSaved(UserFavorites userFavorites, AuthUser authUser) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          // final tiles = _saved.map(
          final tiles = userFavorites.favorties.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return favoriteScaffold(divided, userFavorites, authUser);
        },
      ),
    );
  }


  void _pushedLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {

          return Scaffold(
            appBar: AppBar(
              title: const Text('Login',),
              centerTitle: true,
            ),
            body: const LoginForm(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final wordPair = WordPair.random();
    // return Text(wordPair.asPascalCase);
    return Consumer<UserFavorites>(builder: (context, userFavorites, child){
    return Consumer<AuthUser>(builder: (context, authUser, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => _pushSaved(userFavorites, authUser),
                tooltip: 'Saved Suggestions',
              ),
              Consumer<AuthUser>(builder: (context, authUser, child) {
                if (authUser.status == Status.Authenticated) {
                  // when changing the auth state here, meaning, logged-in, should pull
                  // the favorites from the cloud and merge the local with the pulled
                  // userFavorites.updateFromCloud(authUser);
                  // userFavorites.updateToCloud(authUser);
                  return IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      userFavorites.updateToCloudAndDeleteLocal(authUser);
                      authUser.signOut(context);
                    },
                    tooltip: 'Log out',
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: _pushedLoginScreen,
                    tooltip: 'Login Screen',
                  );
                }
              }),
          ],
        ),
        body: _buildSuggestions(authUser),
      );
    });
    });
  }
}

