import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';

class StudentsSelectorWidget extends StatefulWidget {
  const StudentsSelectorWidget({
    super.key,
    required this.onSelectedStudentsChanged,
    required this.onSubmit,
    required this.students,
    this.selectedStudents = const [],
  });

  final void Function(List<Participant> selectedStudents) onSubmit;
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

  Future<void> _onSubmit() async{
    return widget.onSubmit(_selectedStudents);
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: kAppSeedColor.withOpacity(0.05),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          height: MediaQuery.sizeOf(context).height * 0.5,
          width: double.infinity,
          child: Scrollbar(
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
          ),
        ),

        const SizedBox(height: 12),

        // Next button
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _selectedStudents.isNotEmpty ? _onSubmit : null,
            child: const Text('Add Points'),
          ),
        ),
      ],
    );
  }
}
