import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/instructor.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/pdf_user.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/services/firebase/change_listener.dart';

part 'auth_extension.dart';
part 'camp_extension.dart';
part 'user_extension.dart';
part 'participants_extension.dart';

class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._();

  static FirebaseManager get instance => _instance;

  Stream<ChangeListener<Camp>> get campChangedStream {
    if (_campChangedStreamController != null) {
      return _campChangedStreamController!.stream;
    }

    _campChangedStreamController = StreamController<ChangeListener<Camp>>.broadcast();
    _listenToCampChanges(_campChangedStreamController!);

    return _campChangedStreamController!.stream;
  }

  StreamController<ChangeListener<Camp>>? _campChangedStreamController;

  FirebaseManager._();

  void close() {
    _stopListeningToCampChanges();
  }
}
