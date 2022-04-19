import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/profile_page.dart';
import 'package:hello_me/utils.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'favoritesUtils.dart';
import 'auth_state.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;

void main() {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthUser.instance()),
      ChangeNotifierProvider(create: (context) => UserFavorites()),
      ChangeNotifierProvider(create: (context) => UserProfilePic()),
      ChangeNotifierProvider(create: (context) => ConfirmButton()),
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
              title: const Text(
                'Login',
              ),
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
    final snappingSheetController = SnappingSheetController();

    return ChangeNotifierProvider(
        create: (context) => ProfileSheet(),
        child:
            Consumer<UserFavorites>(builder: (context, userFavorites, child) {
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
                // body: _buildSuggestions(authUser),
                body: !authUser.isAuthenticated
                    ? _buildSuggestions(authUser)
                    : SnappingSheet(
                        controller: snappingSheetController,
                        lockOverflowDrag: true,
                        grabbing: GrabbingWidget(
                            snappingSheetController: snappingSheetController),
                        child: Consumer<ProfileSheet>(
                            builder: (context, profileSheet, child) {
                          return profileSheet.toggleIsOpen ? Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              _buildSuggestions(authUser),
                              BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: profileSheet.toggleIsOpen ? 6.0 : 0.0,
                                  sigmaY: profileSheet.toggleIsOpen ? 6.0 : 0.0,
                                ),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              )
                            ],
                          ) : _buildSuggestions(authUser);
                        }),
                        grabbingHeight: 55,
                        sheetBelow: SnappingSheetContent(
                            draggable: false,
                            child: Container(
                                color: Colors.white,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Consumer<UserProfilePic>(builder:
                                          (context, userProfilePic, child) {
                                        // userProfilePic.updatePicFromCloud(authUser);
                                        return Container(
                                          margin: EdgeInsets.all(20),
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(userProfilePic
                                                        .profilePicRef ??
                                                    'https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'),
                                                fit: BoxFit.cover),
                                          ),
                                        );
                                      }),
                                      Consumer<UserProfilePic>(builder:
                                          (context, userProfilePic, child) {
                                        return Expanded(
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                  '${authUser.user?.email}',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                )),
                                                Flexible(
                                                    child: TextButton(
                                                  onPressed: () async {
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                                type: FileType.custom,
                                                                allowedExtensions: ['jpg', 'png','webp',
                                                                'apng', 'avif', 'jpeg', 'svg', ],
                                                                );
                                                    if (result != null) {
                                                      print(
                                                          "################# in pic");
                                                      String fileName = result
                                                          .files.first.name;
                                                      print(
                                                          "################# in pic $fileName");
                                                      io.File file = io.File(
                                                          result.files.single
                                                              .path!);
                                                      try {
                                                        await FirebaseStorage
                                                            .instance
                                                            .ref(
                                                                'profilePics/$fileName')
                                                            .putFile(file);
                                                        await FirebaseStorage
                                                            .instance
                                                            .ref(
                                                                'profilePics/$fileName')
                                                            .getDownloadURL()
                                                            .then((value) =>
                                                                userProfilePic
                                                                    .updatePicToCloud(
                                                                        authUser,
                                                                        value))
                                                            .then((value) =>
                                                                userProfilePic
                                                                    .updatePicFromCloud(
                                                                        authUser));

                                                        print(
                                                            "####### ${userProfilePic.profilePicRef}");
                                                      } catch (e) {
                                                        print(
                                                            "####### PIC PROBLEM");
                                                      }
                                                    } else {
                                                      showSnackBar(
                                                          context: context,
                                                          text:
                                                              'No image selected');
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    backgroundColor:
                                                        Colors.lightBlue,
                                                  ),
                                                  child: const Text(
                                                      'Change avatar'),
                                                )),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ])))));
          });
          // }),
        }));
  }
}
