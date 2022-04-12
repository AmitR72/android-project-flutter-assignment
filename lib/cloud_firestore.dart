import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings.dart' as settings;

class FirebaseInit {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final String version;

  // FirebaseInit(this.version);
  FirebaseInit();

  DocumentReference db() => _db.collection('versions').doc(settings.version);
}