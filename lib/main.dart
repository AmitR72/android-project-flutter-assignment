import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
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
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
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
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Future<bool> showSnackBarYam(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deletion is not implemented yet')));
    return Future<bool>.value(false);
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
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
                      return await showSnackBarYam(context);
                    },
                    child: divided[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogin() {
    return Form(
        child: Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 20),
          child: const Text(
            'Welcome to Startup Names Generator, please log in below',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            decoration: const InputDecoration(
              // border: OutlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            decoration: const InputDecoration(
              // border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          width: double.infinity, // <-- match_parent
          child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login is not implemented yet')),
            );
          },
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          )),
          // padding: MaterialStateProperty.all<Size>(const EdgeInsets.only(left: Size.infinite, right: 10))
          ),
          child: const Text('Log in')
          ),
        ),
      ],
    ));
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
            body: _buildLogin(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final wordPair = WordPair.random();
    // return Text(wordPair.asPascalCase);
    return Scaffold (
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _pushedLoginScreen,
            tooltip: 'Login Screen',
          ),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}

