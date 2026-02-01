import 'dart:convert';

import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';

class DummyDataUtils {
  static final DummyDataUtils instance = DummyDataUtils._();

  DummyDataUtils._();

  Future<void> addLiftValuePoints() async {
    kLiftDefaultPointsMap.forEach((liftType, points) async {
      await FirebaseManager.instance.addLiftValuePoints(
        liftName: liftType,
        points: points,
        type: kLiftTypeMap[liftType] ?? 'Unknown',
        modifiedAt: DateTime.now(),
        modifiedBy: 'Abi',
      );
    });
  }
}
