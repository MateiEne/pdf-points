import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/add_points.dart';

class AddPointsFab extends StatefulWidget {
  /// The location of the ExpandableFab on the screen.
  static const FloatingActionButtonLocation location = FloatingActionButtonLocation.endFloat;

  const AddPointsFab({
    super.key,
    required this.students,
  });

  final List<Participant> students;

  @override
  State<AddPointsFab> createState() => _AddPointsFabState();
}

class _AddPointsFabState extends State<AddPointsFab> {
  void _openAddPointsDialog() {
    AddPointsModal.show(context: context, students: widget.students, onAddPoints: _onAddPoints);
  }

  Future<void> _onAddPoints(BuildContext modalSheetContext, List<Participant> selectedStudents, String lift) async {
    print("Adding lift: $lift to students: ${selectedStudents.map((s) => s.fullName).toList()}");

    // TODO: add points to firebase:
    await Future.delayed(const Duration(seconds: 1));


    if (!modalSheetContext.mounted) {
      return;
    }

    Navigator.of(modalSheetContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _openAddPointsDialog,
      label: const Text("Add Points"),
      icon: const Icon(Icons.add),
    );
  }
}
