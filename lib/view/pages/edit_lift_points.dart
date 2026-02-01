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

  @override
  void initState() {
    super.initState();

    _initializeControllers();
    _loadPointsFromFirebase();
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

  /// Load points from Firebase and update controllers
  Future<void> _loadPointsFromFirebase() async {
    safeSetState(() => _isLoading = true);

    try {
      List<LiftInfo> liftInfos = await FirebaseManager.instance.fetchAllLiftsInfo();

      // Override controllers values with Firebase data
      for (var liftInfo in liftInfos) {
        _controllers[liftInfo.name]?.text = liftInfo.points.toString();
        _lastSavedPoints[liftInfo.name] = liftInfo.points;
      }
    } catch (e) {
      debugPrint('Error loading lift points: $e');
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  /// Save all lift points to Firebase in a single batch operation
  Future<void> _savePoints() async {
    safeSetState(() => _isLoading = true);

    try {
      final liftsPoints = <String, int>{};
      final liftsTypes = <String, String>{};

      // Gather all current values
      _controllers.forEach((liftName, controller) {
        final points = int.tryParse(controller.text) ?? 0;

        liftsPoints[liftName] = points;
        liftsTypes[liftName] = kLiftTypeMap[liftName] ?? 'Unknown';

        _lastSavedPoints[liftName] = points;
      });

      // Batch save to Firebase
      await FirebaseManager.instance.updateAllLiftValuePoints(
        liftsPoints: liftsPoints,
        liftsTypes: liftsTypes,
        modifiedAt: DateTime.now(),
        modifiedBy: widget.instructor.shortName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarSuccess('Points saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error saving points: $e');
      }
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  /// Reset all points to default values from constants
  void _resetToDefaults() {
    _updateAllControllers((liftName) => kLiftDefaultPointsMap[liftName] ?? 0);

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to default values');
  }

  /// Reset all points to last saved values
  void _resetToLastSaved() {
    _updateAllControllers((liftName) => _lastSavedPoints[liftName] ?? 0);

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to last saved values');
  }

  /// Helper method to update all controllers with values from a function
  void _updateAllControllers(int Function(String) getPoints) {
    safeSetState(() {
      _controllers.forEach((liftName, controller) {
        controller.text = getPoints(liftName).toString();
      });
    });
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Lift Icon
            Image.asset(
              icon,
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 12),

            // Lift Name
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Points Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease button
                IconButton(
                  onPressed: () => _decrementPoints(controller),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red.shade900,
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(width: 6),

                // Points display
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Increase button
                IconButton(
                  onPressed: () => _incrementPoints(controller),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green.shade900,
                  iconSize: 28,
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
      int currentValue = int.tryParse(controller.text) ?? 0;
      controller.text = (currentValue + 1).toString();
    });
  }

  void _decrementPoints(TextEditingController controller) {
    setState(() {
      int currentValue = int.tryParse(controller.text) ?? 0;
      if (currentValue > 0) {
        controller.text = (currentValue - 1).toString();
      }
    });
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
            padding: const EdgeInsets.all(16.0),
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
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _savePoints,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppSeedColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save Lift Points',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
}
