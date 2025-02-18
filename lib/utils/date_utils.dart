import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension DateTimeUtils on DateTime {
  String format({datePattern = 'E dd-MM-yyyy'}) {
    final dateFormat = DateFormat(datePattern);
    return dateFormat.format(this);
  }

  String toDateString() {
    return format(datePattern: 'E dd-MM-yyyy');
  }

  String toTimeString() {
    return format(datePattern: 'h:mm a');
  }

  Timestamp toTimestamp() {
    return Timestamp.fromDate(this);
  }

  bool isTheSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isBeforeOrEqual(DateTime other) {
    return isBefore(other) || other == this;
  }

  DateTime nextYear() {
    return copyWith(year: year + 1);
  }

  static DateTime today() {
    return DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }
}
