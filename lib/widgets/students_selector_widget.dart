import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';

class StudentsSelectorWidget extends StatefulWidget {
  const StudentsSelectorWidget({
    super.key,
    required this.onSelectedStudentsChanged,
    required this.students,
    this.selectedStudents = const [],
  });

  final void Function(List<Participant> selectedStudents) onSelectedStudentsChanged;
  final List<Participant> students;
  final List<Participant> selectedStudents;

  @override
  State<StudentsSelectorWidget> createState() => _StudentsSelectorWidgetState();
}

class _StudentsSelectorWidgetState extends State<StudentsSelectorWidget> {
  final List<Participant> _selectedStudents = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectedStudents.addAll(widget.selectedStudents);
  }

  void _onSelectedStudentChanged(Participant student, bool selected) {
    setState(() {
      if (selected) {
        _selectedStudents.add(student);
      } else {
        _selectedStudents.removeWhere((s) => s.id == student.id);
      }
    });

    widget.onSelectedStudentsChanged(_selectedStudents);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        // use shrinkWrap: true since the listview has few items
        shrinkWrap: true,
        controller: _scrollController,
        padding: const EdgeInsets.all(0),
        itemCount: widget.students.length,
        itemBuilder: (context, index) {
          bool selected = _selectedStudents.any((s) => s.id == widget.students[index].id);

          return CheckboxListTile(
            title: Text(
              widget.students[index].fullName,
              style: selected //
                  ? const TextStyle(fontWeight: FontWeight.w600)
                  : null,
            ),
            value: selected,
            onChanged: (value) {
              if (value == null) return;

              _onSelectedStudentChanged(widget.students[index], value);
            },
          );
        },
      ),
    );
  }
}
