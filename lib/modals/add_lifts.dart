import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/instructor.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/data/lift_user.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/widgets/lift_users_selector_widget.dart';
import 'package:pdf_points/widgets/lifts_selector_widget.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddLiftsModal {
  static String _defaultLift = kGondolas.first;
  static String _defaultLiftType = kGondola;
  static final List<LiftUser> _selectedLiftUsers = [];
  static final ValueNotifier<bool> _isButtonEnabledNotifier = ValueNotifier(false);

  static Future<void> show({
    required BuildContext context,
    required String campId,
    required Instructor instructor,
    required List<LiftUser> students,
  }) {
    return WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        _checkSelectedStudents(instructor, students);

        return [
          // Select lift page
          _selectLiftPage(modalSheetContext),

          // Select students page
          _selectStudentsPage(modalSheetContext, campId, instructor, students),
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

  static void _checkSelectedStudents(Instructor instructor, List<LiftUser> students) {
    // remove selected students that are not in the list of students
    _selectedLiftUsers.removeWhere((student) => !students.contains(student));

    if (_selectedLiftUsers.isEmpty) {
      _selectedLiftUsers.addAll(students);
    }

    // add the instructor
    if (!_selectedLiftUsers.contains(instructor)) {
      _selectedLiftUsers.add(instructor);
    }

    _isButtonEnabledNotifier.value = _selectedLiftUsers.isNotEmpty;
  }

  static WoltModalSheetPage _selectLiftPage(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      topBarTitle: Text(
        'Select Lift',
        style: Theme.of(modalSheetContext).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
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
          height: MediaQuery.sizeOf(modalSheetContext).height * 0.5,
          child: Builder(builder: (context) {
            return LiftsSelectorWidget(
              defaultLift: _defaultLift,
              onLiftSelected: (String lift, String liftType) {
                _defaultLift = lift;
                _defaultLiftType = liftType;
              },
            );
          }),
        ),
      ),
    );
  }

  static WoltModalSheetPage _selectStudentsPage(
    BuildContext modalSheetContext,
    String campId,
    Instructor instructor,
    List<LiftUser> students,
  ) {
    return WoltModalSheetPage(
      topBarTitle: Text(
        'Select Participants',
        style: Theme.of(modalSheetContext).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
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
      stickyActionBar: ValueListenableBuilder<bool>(
        valueListenable: _isButtonEnabledNotifier,
        builder: (BuildContext context, bool enable, Widget? child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedAutoLoadingButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppSeedColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.maxFinite, 56),
                maximumSize: const Size(double.maxFinite, 56),
              ),
              onPressed: enable
                  ? () async {
                      await _addLifts(campId, instructor, _selectedLiftUsers, _defaultLift, _defaultLiftType);

                      if (!modalSheetContext.mounted) return;

                      Navigator.of(modalSheetContext).pop();
                    }
                  : null,
              child: const Text('Add Lifts'),
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0).add(const EdgeInsets.only(bottom: 56 + 16)),
        child: Container(
          decoration: BoxDecoration(
            color: kAppSeedColor.withOpacity(0.05),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Builder(builder: (context) {
            return LiftUsersSelectorWidget(
              liftUsers: [instructor, ...students],
              selectedLiftUsers: _selectedLiftUsers,
              onSelectedLiftUsersChanged: (List<LiftUser> liftUsers) {
                _selectedLiftUsers.clear();
                _selectedLiftUsers.addAll(liftUsers);

                _isButtonEnabledNotifier.value = _selectedLiftUsers.isNotEmpty;
              },
            );
          }),
        ),
      ),
    );
  }

  static Future<void> _addLifts(
    String campId,
    Instructor instructor,
    List<LiftUser> selectedLiftUsers,
    String lift,
    String liftType,
  ) async {
    for (final liftUser in selectedLiftUsers) {
      await FirebaseManager.instance.addLift(
        campId: campId,
        lift: LiftInfo(
          name: lift,
          type: liftType,
          personId: liftUser.id,
          createdAt: DateTime.now(),
          createdBy: instructor.id,
        ),
      );
    }
  }
}
