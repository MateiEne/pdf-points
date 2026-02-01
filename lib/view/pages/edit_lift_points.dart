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
  List<LiftInfo> _liftInfos = [];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _lastSavedPoints = {};

  @override
  void initState() {
    super.initState();

    _initializeControllers();
    _loadDefaultPoints();
    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchLiftInfos();
  }

  Future<void> _fetchLiftInfos() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<LiftInfo> liftInfos = await FirebaseManager.instance.fetchAllLiftsInfo();

      safeSetState(() {
        _isLoading = false;
        _liftInfos = liftInfos;

        // Update controllers with Firebase data
        for (var liftInfo in _liftInfos) {
          if (_controllers.containsKey(liftInfo.name)) {
            _controllers[liftInfo.name]!.text = liftInfo.points.toString();
            _lastSavedPoints[liftInfo.name] = liftInfo.points;
          }
        }
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching lift infos: $e');
    }
  }

  void _initializeControllers() {
    // Initialize controllers for all lifts
    for (var lift in kCableCars) {
      _controllers[lift] = TextEditingController();
    }
    for (var lift in kGondolas) {
      _controllers[lift] = TextEditingController();
    }
    for (var lift in kChairlifts) {
      _controllers[lift] = TextEditingController();
    }
    for (var lift in kSkilifts) {
      _controllers[lift] = TextEditingController();
    }
  }

  void _loadDefaultPoints() {
    // Load default values from kLiftDefaultPointsMap
    _controllers.forEach((liftName, controller) {
      final points = kLiftDefaultPointsMap[liftName] ?? 0;
      controller.text = points.toString();
      _lastSavedPoints[liftName] = points;
    });
  }

  Future<void> _savePoints() async {
    try {
      safeSetState(() {
        _isLoading = true;
      });

      // Prepare data for batch update
      final Map<String, int> liftsPoints = {};
      final Map<String, String> liftsTypes = {};

      for (var entry in _controllers.entries) {
        final liftName = entry.key;
        final points = int.tryParse(entry.value.text) ?? 0;

        liftsPoints[liftName] = points;
        liftsTypes[liftName] = _getLiftType(liftName);

        // Store as last saved
        _lastSavedPoints[liftName] = points;
      }

      // Save all lifts in one batch operation
      await FirebaseManager.instance.updateAllLiftValuePoints(
        liftsPoints: liftsPoints,
        liftsTypes: liftsTypes,
        modifiedAt: DateTime.now(),
        modifiedBy: widget.instructor.shortName,
      );

      safeSetState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarSuccess(('Points saved successfully!'));
        // Navigator.pop(context);
      }
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error saving points: $e');
      }
    }
  }

  String _getLiftType(String liftName) {
    if (kCableCars.contains(liftName)) return kCableCar;
    if (kGondolas.contains(liftName)) return kGondola;
    if (kChairlifts.contains(liftName)) return kChairlift;
    if (kSkilifts.contains(liftName)) return kSkilift;
    return 'Unknown';
  }

  void _resetToDefaults() {
    setState(() {
      _controllers.forEach((liftName, controller) {
        final points = kLiftDefaultPointsMap[liftName] ?? 0;
        controller.text = points.toString();
      });
    });

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to default values');
  }

  void _resetToLastSaved() {
    setState(() {
      _controllers.forEach((liftName, controller) {
        final points = _lastSavedPoints[liftName] ?? 0;
        controller.text = points.toString();
      });
    });

    ScaffoldMessenger.of(context).showSnackBarSuccess('Reset to last saved values');
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
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
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
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
}
