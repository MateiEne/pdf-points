import 'package:pdf_points/data/participant.dart';

class ExcelCamp {
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Participant> participants;

  ExcelCamp({
    this.name,
    this.startDate,
    this.endDate,
    this.participants = const [],
  });

  @override
  String toString() {
    return 'ExcelCamp(name: $name, startDate: $startDate, endDate: $endDate, ${participants.length} participants)';
  }
}
