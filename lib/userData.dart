import 'package:english_words/english_words.dart';

class UserData{
  String? _email;
  String? _password;
  List<WordPair>? _favorites;

  UserData(this._email, this._password, this._favorites);
  // UserData copyWith(UserData user) =>
  //     UserData(user.email, user.password, user.favorites);

  String? get email => _email;
  String? get password => _password;
  List<WordPair>? get favorites => _favorites;
}