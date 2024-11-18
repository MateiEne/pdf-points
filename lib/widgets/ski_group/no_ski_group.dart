import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/modals/add_ski_group.dart';

class NoSkiGroup extends StatelessWidget {
  const NoSkiGroup({
    super.key,
    required this.instructor,
    required this.onAddSkiGroup,
  });

  final Participant instructor;
  final void Function(SkiGroup skiGroup) onAddSkiGroup;

  void _addSkiGroup(BuildContext context) {
    AddSkiGroupModal.show(context: context, onAddSkiCamp: _onAddSkiCamp);
  }

  Future<void> _onAddSkiCamp(BuildContext modalSheetContext, String name) async {
    // TODO: save the group to firebase:
    // FirebaseManager.instance.addSkiGroup(
    //   name: _name,
    //   ...
    // );
    await Future.delayed(const Duration(seconds: 1));

    if (!modalSheetContext.mounted) return;

    onAddSkiGroup(SkiGroup(name: name, instructor: instructor));

    Navigator.of(modalSheetContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // top padding
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

        // Title
        Text(
          "You don't have a group yet.",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 48),

        // Instructions to add ski group
        Text(
          '1. First create your group',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '2. Then add your participants',
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        const SizedBox(height: 32),

        // Add ski group button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            maximumSize: const Size(double.infinity, 56),
          ),
          onPressed: () => _addSkiGroup(context),
          child: const Center(
            child: Text('Create Your Group'),
          ),
        ),
      ],
    );
    ;
  }
}
