import 'package:pdf_points/data/participant.dart';

class SkiGroup {
  final String name;
  final String? image;
  final List<Participant> participants;
  final Participant instructor;

  SkiGroup({
    required this.name,
    required this.instructor,
    this.image,
    this.participants = const [],
  });

  @override
  String toString() {
    return 'SkiGroup{name: $name, image: $image,  ${participants.length} participants, instructor: $instructor}';
  }
}