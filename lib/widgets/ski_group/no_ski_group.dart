import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/widgets/ski_group/add_ski_group_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class NoSkiGroup extends StatelessWidget {
  const NoSkiGroup({
    super.key,
    required this.instructor,
    required this.onAddSkiGroup,
  });

  final Participant instructor;
  final void Function(SkiGroup skiGroup) onAddSkiGroup;

  void _addSkiGroup(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Create Group',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16.0),
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(modalSheetContext).pop,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AddSkiGroupContentWidget(
              defaultName: "${instructor.shortName}'s Group",
              onAddSkiCamp: (name) => _onAddSkiCamp(modalSheetContext, name),
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        final size = MediaQuery.sizeOf(context).width;

        return size < kPageWidthBreakpoint //
            ? const WoltBottomSheetType()
            : const WoltDialogType();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
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
