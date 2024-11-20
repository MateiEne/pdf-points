import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/widgets/lifts_selector_widget.dart';
import 'package:pdf_points/widgets/students_selector_widget.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddPointsModal {
  static Future<void> show({
    required BuildContext context,
    required List<Participant> students,
    required Future<void> Function(
      BuildContext context,
      List<Participant> selectedStudents,
      String lift,
    ) onAddPoints,
  }) {
    return WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        String? defaultLift;
        List<Participant> selectedStudents = students;

        return [
          // Select lift page
          WoltModalSheetPage(
            topBarTitle: Text(
              'Select Lift',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              padding: const EdgeInsets.all(16),
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(modalSheetContext).pop();
              },
            ),
            hasSabGradient: true,
            stickyActionBar: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: WoltModalSheet.of(modalSheetContext).showNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppSeedColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.maxFinite, 56),
                ),
                child: const Text("Next"),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0).add(const EdgeInsets.only(bottom: 56 + 16)),
              child: Container(
                decoration: BoxDecoration(
                  color: kAppSeedColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: Builder(builder: (context) {
                  return LiftsSelectorWidget(
                    defaultLift: defaultLift,
                    onLiftSelected: (String lift) {
                      defaultLift = lift;
                    },
                  );
                }),
              ),
            ),
          ),

          // Select students page
          WoltModalSheetPage(
            topBarTitle: Text(
              'Select Participants',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              padding: const EdgeInsets.all(16),
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(modalSheetContext).pop();
              },
            ),
            leadingNavBarWidget: IconButton(
              padding: const EdgeInsets.all(16),
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: WoltModalSheet.of(modalSheetContext).showPrevious,
            ),
            // hasSabGradient: false,
            stickyActionBar: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedAutoLoadingButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppSeedColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.maxFinite, 56),
                  maximumSize: const Size(double.maxFinite, 56),
                ),
                onPressed: selectedStudents.isNotEmpty
                    ? () {
                        return onAddPoints(modalSheetContext, selectedStudents, defaultLift!);
                      }
                    : null,
                child: const Text('Add Points'),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0).add(const EdgeInsets.only(bottom: 56 + 16)),
              child: Container(
                decoration: BoxDecoration(
                  color: kAppSeedColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Builder(builder: (context) {
                  return StudentsSelectorWidget(
                    students: students,
                    selectedStudents: selectedStudents,
                    onSelectedStudentsChanged: (List<Participant> students) {
                      selectedStudents = students;
                    },
                  );
                }),
              ),
            ),
          ),
        ];
      },
      modalTypeBuilder: (context) {
        // return const WoltDialogType();

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
}
