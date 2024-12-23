import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';

part 'camp_extension.dart';


class FirebaseManager {
  FirebaseManager._();

  static final FirebaseManager _instance = FirebaseManager._();

  static FirebaseManager get instance => _instance;

  void close() {}
}
