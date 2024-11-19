import 'package:pdf_points/data/participant.dart';

class SkiGroup {
  final String name;
  final String? image;
  final List<Participant> participants = [];
  final Participant instructor;

  SkiGroup({
    required this.name,
    required this.instructor,
    this.image,
    List<Participant> participants = const [],
  }) {
    this.participants.addAll(participants);
  }

  void addParticipant(Participant participant) {
    participants.add(participant);
  }

  @override
  String toString() {
    return 'SkiGroup{name: $name, image: $image,  ${participants.length} participants, instructor: $instructor}';
  }
}