import 'package:pdf_points/data/participant.dart';

class ExcelCampInfo {
  final String? name;
  final DateTime? startSkiDate;
  final DateTime? endSkiDate;
  final List<Participant> participants;

  ExcelCampInfo({
    this.name,
    this.startSkiDate,
    this.endSkiDate,
    this.participants = const [],
  });

  @override
  String toString() {
    return 'ExcelCampInfo(name: $name, startSkiDate: $startSkiDate, endSkiDate: $endSkiDate, ${participants.length} participants)';
  }
}
