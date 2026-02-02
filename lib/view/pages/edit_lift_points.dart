import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';

class EditLiftPointsScreen extends StatefulWidget {
  final Instructor instructor;

  const EditLiftPointsScreen({super.key, required this.instructor});

  @override
  State<EditLiftPointsScreen> createState() => _EditLiftPointsScreenState();
}

class _EditLiftPointsScreenState extends State<EditLiftPointsScreen> {
  bool _isLoading = true;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _lastSavedPoints = {};
  final Map<String, int> _originalFirebasePoints = {}; // Track original values from Firebase
  final Map<String, LiftInfo> _liftInfoMap = {}; // Store complete LiftInfo for metadata
  final Map<String, bool> _selectedLifts = {}; // Track which lifts are selected for saving

  StreamSubscription<List<LiftInfo>>? _liftsStreamSubscription;

  @override
  void initState() {
    super.initState();

    _initializeControllers();
    _listenToLiftPointsChanges();
  }

  /// Initialize text controllers for all lift types
  void _initializeControllers() {
    final allLifts = [...kCableCars, ...kGondolas, ...kChairlifts, ...kSkilifts];

    for (var liftName in allLifts) {
      _controllers[liftName] = TextEditingController();

      // Set default points from constants
      final defaultPoints = kLiftDefaultPointsMap[liftName] ?? 0;
      _controllers[liftName]!.text = defaultPoints.toString();
      _lastSavedPoints[liftName] = defaultPoints;
    }
  }

  /// Listen to real-time changes in lift points from Firebase
  void _listenToLiftPointsChanges() {
    safeSetState(() => _isLoading = true);

    _liftsStreamSubscription = FirebaseManager.instance.listenToAllLiftsInfo().listen(
      (liftInfos) {
        if (!mounted) return;

        // Update controllers with Firebase data
        for (var liftInfo in liftInfos) {
          // Only update if user hasn't manually edited this field
          final currentValue = int.tryParse(_controllers[liftInfo.name]?.text ?? '0') ?? 0;
          final originalValue = _originalFirebasePoints[liftInfo.name] ?? 0;

          // If user hasn't modified this value locally, update with Firebase value
          if (currentValue == originalValue) {
            _controllers[liftInfo.name]?.text = liftInfo.points.toString();
          }

          _lastSavedPoints[liftInfo.name] = liftInfo.points;
          _originalFirebasePoints[liftInfo.name] = liftInfo.points;
          _liftInfoMap[liftInfo.name] = liftInfo;
        }

        safeSetState(() => _isLoading = false);
      },
      onError: (error) {
        debugPrint('Error listening to lift points: $error');
        safeSetState(() => _isLoading = false);
      },
    );
  }

  /// Save only selected lift points to Firebase in a batch operation
  Future<void> _savePoints() async {
    safeSetState(() => _isLoading = true);

    try {
      final liftsPoints = <String, int>{};
      final liftsTypes = <String, String>{};

      // Gather only selected lifts
      _selectedLifts.forEach((liftName, isSelected) {
        if (isSelected) {
          final currentPoints = int.tryParse(_controllers[liftName]?.text ?? '0') ?? 0;
          liftsPoints[liftName] = currentPoints;
          liftsTypes[liftName] = _getLiftType(liftName);
          _lastSavedPoints[liftName] = currentPoints;
          _originalFirebasePoints[liftName] = currentPoints; // Update original
        }
      });

      // Only save if there are selected lifts
      if (liftsPoints.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBarSuccess('No lifts selected to save');
        }
        return;
      }

      // Batch save selected lifts to Firebase
      await FirebaseManager.instance.updateAllLiftValuePoints(
        liftsPoints: liftsPoints,
        liftsTypes: liftsTypes,
        modifiedAt: DateTime.now(),
        modifiedBy: widget.instructor.shortName,
      );

      // Uncheck all checkboxes after successful save
      safeSetState(() {
        _selectedLifts.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarSuccess(
          'Saved ${liftsPoints.length} lift${liftsPoints.length > 1 ? 's' : ''}!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error saving points: $e');
      }
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  /// Determine lift type based on lift name
  String _getLiftType(String liftName) {
    if (kCableCars.contains(liftName)) return kCableCar;
    if (kGondolas.contains(liftName)) return kGondola;
    if (kChairlifts.contains(liftName)) return kChairlift;
    if (kSkilifts.contains(liftName)) return kSkilift;
    return 'Unknown';
  }

  /// Reset all points to default values from constants and auto-select modified ones
  void _resetToDefaults() {
    safeSetState(() {
      _selectedLifts.clear();

      _controllers.forEach((liftName, controller) {
        final defaultPoints = kLiftDefaultPointsMap[liftName] ?? 0;
        controller.text = defaultPoints.toString();

        // Auto-select if different from Firebase value
        final firebasePoints = _originalFirebasePoints[liftName] ?? _lastSavedPoints[liftName] ?? 0;
        if (defaultPoints != firebasePoints) {
          _selectedLifts[liftName] = true;
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to default values');
  }

  /// Reset all points to last saved values and clear selections
  void _resetToLastSaved() {
    safeSetState(() {
      _selectedLifts.clear();

      _controllers.forEach((liftName, controller) {
        final savedPoints = _lastSavedPoints[liftName] ?? 0;
        controller.text = savedPoints.toString();
      });
    });

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to last saved values');
  }

  List<Widget> _buildLiftSection(List<String> lifts, String icon) {
    List<Widget> widgets = [];
    for (var lift in lifts) {
      widgets.add(
        _buildLiftPointRow(
          icon: icon,
          name: lift,
          controller: _controllers[lift]!,
        ),
      );
      widgets.add(const SizedBox(height: 4));
    }
    return widgets;
  }

  Widget _buildLiftPointRow({
    required String icon,
    required String name,
    required TextEditingController controller,
  }) {
    final liftInfo = _liftInfoMap[name];
    final hasModificationInfo = liftInfo != null;
    final currentPoints = int.tryParse(controller.text) ?? 0;
    final firebasePoints = _originalFirebasePoints[name] ?? _lastSavedPoints[name] ?? 0;
    final isModified = currentPoints != firebasePoints;
    final isSelected = _selectedLifts[name] ?? false;

    return Card(
      elevation: 2,
      // if selected, color is card color; else default
      color: isSelected
          ? Color.lerp(
              Theme.of(context).colorScheme.surface,
              kAppSeedColor,
              0.3,
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              fillColor: isModified ? WidgetStatePropertyAll(kAppSeedColor) : null,
              onChanged: isModified
                  ? null
                  : (value) {
                      if (!isModified) {
                        setState(() {
                          _selectedLifts[name] = value ?? false;
                        });
                      }
                    },
            ),
            // Lift Icon
            Image.asset(
              icon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),

            // Lift Name and Modification Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (hasModificationInfo) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatModificationInfo(liftInfo),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Points Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease button
                IconButton(
                  onPressed: () => _decrementPoints(controller),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red.shade900,
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(width: 4),

                // Points display
                Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(width: 4),

                // Increase button
                IconButton(
                  onPressed: () => _incrementPoints(controller),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green.shade900,
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _incrementPoints(TextEditingController controller) {
    setState(() {
      // Find which lift this controller belongs to
      String? liftName;
      _controllers.forEach((name, ctrl) {
        if (ctrl == controller) liftName = name;
      });

      int currentValue = int.tryParse(controller.text) ?? 0;
      final newValue = currentValue + 1;
      controller.text = newValue.toString();

      // Auto-check/uncheck checkbox based on whether value matches Firebase
      if (liftName != null) {
        final firebasePoints = _originalFirebasePoints[liftName!] ?? _lastSavedPoints[liftName!] ?? 0;
        if (newValue == firebasePoints) {
          // Value matches Firebase - uncheck
          _selectedLifts[liftName!] = false;
        } else {
          // Value differs from Firebase - check
          _selectedLifts[liftName!] = true;
        }
      }
    });
  }

  void _decrementPoints(TextEditingController controller) {
    setState(() {
      // Find which lift this controller belongs to
      String? liftName;
      _controllers.forEach((name, ctrl) {
        if (ctrl == controller) liftName = name;
      });

      int currentValue = int.tryParse(controller.text) ?? 0;
      if (currentValue > 0) {
        final newValue = currentValue - 1;
        controller.text = newValue.toString();

        // Auto-check/uncheck checkbox based on whether value matches Firebase
        if (liftName != null) {
          final firebasePoints = _originalFirebasePoints[liftName!] ?? _lastSavedPoints[liftName!] ?? 0;
          if (newValue == firebasePoints) {
            // Value matches Firebase - uncheck
            _selectedLifts[liftName!] = false;
          } else {
            // Value differs from Firebase - check
            _selectedLifts[liftName!] = true;
          }
        }
      }
    });
  }

  /// Format modification info to display when and by whom it was last modified
  String _formatModificationInfo(LiftInfo liftInfo) {
    final now = DateTime.now();
    final modifiedAt = liftInfo.modifiedAt;

    // Normalize to compare calendar days, not 24-hour periods
    final today = DateTime(now.year, now.month, now.day);
    final modifiedDay = DateTime(modifiedAt.year, modifiedAt.month, modifiedAt.day);
    final daysDifference = today.difference(modifiedDay).inDays;

    String timeAgo;
    if (daysDifference == 0) {
      timeAgo = 'today';
    } else {
      timeAgo = '${daysDifference}d ago';
    }

    return '${liftInfo.points}p • Modified $timeAgo by ${liftInfo.modifiedBy}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lift Points'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Cable Cars
                      ..._buildLiftSection(kCableCars, kCableCarIcon),

                      // Gondolas
                      ..._buildLiftSection(kGondolas, kGondolaIcon),

                      // Chairlifts
                      ..._buildLiftSection(kChairlifts, kChairliftIcon),

                      // Skilifts
                      ..._buildLiftSection(kSkilifts, kSkiliftIcon),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Reset buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetToDefaults,
                        icon: const Icon(Icons.restart_alt, size: 20),
                        label: const Text('Reset Defaults'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetToLastSaved,
                        icon: const Icon(Icons.history, size: 20),
                        label: const Text('Reset Last Saved'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedLifts.values.any((v) => v) ? _savePoints : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppSeedColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      maximumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      _selectedLifts.values.any((v) => v)
                          ? 'Update ${_selectedLifts.values.where((v) => v).length} Lifts Points'
                          : 'Update Lifts Points',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator overlay
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _liftsStreamSubscription?.cancel();
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
}
