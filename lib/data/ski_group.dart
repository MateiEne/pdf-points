import 'package:pdf_points/data/instructor.dart';
import 'package:pdf_points/data/participant.dart';

class SkiGroup {
  final String id;
  final String name;
  final String? image;
  final Instructor instructor;
  final List<Participant> _students = [];

  SkiGroup({
    required this.id,
    required this.name,
    required this.instructor,
    this.image,
    List<Participant> students = const [],
  }) {
    _students.addAll(students);
  }

  get hasStudents => _students.isNotEmpty;

  get students => _students.toList();

  void addStudent(Participant participant) {
    _students.add(participant);
  }

  @override
  String toString() {
    return 'SkiGroup{name: $name, image: $image,  ${students.length} students, instructor: $instructor}';
  }
}
