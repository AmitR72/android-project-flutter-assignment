import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings.dart' as settings;

class FirebaseInit {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseInit();

  DocumentReference db() => _db.collection('versions').doc(settings.version);
}