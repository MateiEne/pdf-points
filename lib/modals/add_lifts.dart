import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_user.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/services/preferences_service.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:pdf_points/view/widgets/lift_users_selector_widget.dart';
import 'package:pdf_points/view/widgets/lifts_selector_widget.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'update_lift_points.dart';

class AddLiftsModal {
  static String _defaultLift = kGondolas.first;
  static String _defaultLiftType = kGondola;
  static final List<LiftUser> _selectedLiftUsers = [];
  static final List<LiftUser> _unselectedLiftUsers = [];
  static final ValueNotifier<bool> _isButtonEnabledNotifier = ValueNotifier(false);
  static PreferencesService? _prefsService;
  static bool _prefsInitialized = false;

  static Future<void> show({
    required BuildContext context,
    required String campId,
    required Instructor instructor,
    required List<LiftUser> students,
  }) async {
    // Initialize preferences service if not already initialized
    if (!_prefsInitialized) {
      await _initializePreferences();
    }

    // Load saved preferences
    await _loadPreferences(instructor, students);

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

    // remove unselected students that are not in the list of students
    _unselectedLiftUsers.removeWhere((student) => !students.contains(student));

    if (_selectedLiftUsers.isEmpty) {
      _selectedLiftUsers.addAll(students);
    }

    // add the instructor
    if (!_selectedLiftUsers.contains(instructor)) {
      _selectedLiftUsers.add(instructor);
    }

    // if a student in not selected and is not in the unselected list, add it (must be a new student)
    for (final student in students) {
      if (!_selectedLiftUsers.contains(student) && !_unselectedLiftUsers.contains(student)) {
        _selectedLiftUsers.add(student);
      }
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
            color: kAppSeedColor.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          height: MediaQuery.sizeOf(modalSheetContext).height * 0.4,
          child: Builder(builder: (context) {
            return LiftsSelectorWidget(
              defaultLift: _defaultLift,
              onLiftSelected: (String lift, String liftType) async {
                _defaultLift = lift;
                _defaultLiftType = liftType;
                // Save preferences immediately when lift is changed
                await _savePreferences();
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

                      _showUpdateLiftPointsModalIfNeeded(context, _defaultLift, instructor);

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
            color: kAppSeedColor.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Builder(builder: (context) {
            return LiftUsersSelectorWidget(
              liftUsers: [instructor, ...students],
              selectedLiftUsers: _selectedLiftUsers,
              onSelectedLiftUsersChanged: (List<LiftUser> liftUsers) async {
                final allUsers = [instructor, ...students];

                _selectedLiftUsers.clear();
                _selectedLiftUsers.addAll(liftUsers);

                _unselectedLiftUsers.clear();
                _unselectedLiftUsers.addAll(
                  allUsers.where((user) => !liftUsers.contains(user)),
                );

                _isButtonEnabledNotifier.value = _selectedLiftUsers.isNotEmpty;

                // Save preferences immediately when user selection changes
                await _savePreferences();
              },
            );
          }),
        ),
      ),
    );
  }

  static void _showUpdateLiftPointsModalIfNeeded(BuildContext context, String liftName, Instructor instructor) async {
    final liftInfo = await FirebaseManager.instance.fetchLiftInfo(liftName);
    if (liftInfo == null) {
      if (context.mounted) {
        // TODO: better error handling
        ScaffoldMessenger.of(context).showSnackBarError(
          "Failed to fetch lift info for '$liftName'. Please try updating the points manually.",
        );
      }
      return;
    }

    if (context.mounted && liftInfo.isNotModifiedToday()) {
      if (context.mounted) {
        UpdateLiftPointsModal.show(
          context: context,
          liftInfo: liftInfo,
          instructor: instructor,
        );
      }
    }
  }

  static Future<void> _addLifts(
    String campId,
    Instructor instructor,
    List<LiftUser> selectedLiftUsers,
    String liftName,
    String liftType,
  ) async {
    // Save preferences before adding lifts
    await _savePreferences();

    for (final liftUser in selectedLiftUsers) {
      await FirebaseManager.instance.addLift(
        campId: campId,
        liftName: liftName,
        liftType: liftType,
        participantId: liftUser.id,
        instructorId: instructor.id,
      );
    }
  }

  // Initialize preferences service
  static Future<void> _initializePreferences() async {
    _prefsService = await PreferencesService.getInstance();
    _prefsInitialized = true;
  }

  // Load saved preferences
  static Future<void> _loadPreferences(Instructor instructor, List<LiftUser> students) async {
    if (_prefsService == null) return;

    // Load default lift
    final savedLift = _prefsService!.getDefaultLift();
    if (savedLift != null) {
      _defaultLift = savedLift;
    }

    // Load default lift type
    final savedLiftType = _prefsService!.getDefaultLiftType();
    if (savedLiftType != null) {
      _defaultLiftType = savedLiftType;
    }

    // Load selected lift users
    final savedSelectedIds = _prefsService!.getSelectedLiftUserIds();
    if (savedSelectedIds.isNotEmpty) {
      _selectedLiftUsers.clear();
      final allUsers = [instructor, ...students];
      for (final id in savedSelectedIds) {
        final user = allUsers.firstWhere(
          (u) => u.id == id,
          orElse: () => instructor, // fallback to instructor if not found
        );
        if (!_selectedLiftUsers.contains(user)) {
          _selectedLiftUsers.add(user);
        }
      }
    }

    // Load unselected lift users
    final savedUnselectedIds = _prefsService!.getUnselectedLiftUserIds();
    if (savedUnselectedIds.isNotEmpty) {
      _unselectedLiftUsers.clear();
      final allUsers = [instructor, ...students];
      for (final id in savedUnselectedIds) {
        final user = allUsers.firstWhere(
          (u) => u.id == id,
          orElse: () => instructor, // fallback to instructor if not found
        );
        if (!_unselectedLiftUsers.contains(user)) {
          _unselectedLiftUsers.add(user);
        }
      }
    }
  }

  // Save current preferences
  static Future<void> _savePreferences() async {
    if (_prefsService == null) return;

    await _prefsService!.saveDefaultLift(_defaultLift);
    await _prefsService!.saveDefaultLiftType(_defaultLiftType);
    await _prefsService!.saveSelectedLiftUsers(_selectedLiftUsers);
    await _prefsService!.saveUnselectedLiftUsers(_unselectedLiftUsers);
  }
}
