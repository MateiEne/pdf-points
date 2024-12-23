import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeListener<T> {
  final DocumentChangeType type;
  final T object;

  ChangeListener(this.type, this.object);
}
