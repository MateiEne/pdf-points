import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';

class EditLiftPointsScreen extends StatefulWidget {
  const EditLiftPointsScreen({super.key});

  @override
  State<EditLiftPointsScreen> createState() => _EditLiftPointsScreenState();
}

class _EditLiftPointsScreenState extends State<EditLiftPointsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _lastSavedPoints = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCurrentPoints();
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

  void _loadCurrentPoints() {
    // TODO: Load from Firebase or SharedPreferences
    // Load default values from kLiftDefaultPointsMap
    _controllers.forEach((liftName, controller) {
      final points = kLiftDefaultPointsMap[liftName] ?? 0;
      controller.text = points.toString();
      _lastSavedPoints[liftName] = points; // Initialize last saved
    });
  }

  Future<void> _savePoints() async {
    // Store current values as last saved
    _controllers.forEach((liftName, controller) {
      _lastSavedPoints[liftName] = int.tryParse(controller.text) ?? 0;
    });
    
    // TODO: Save to Firebase or SharedPreferences
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Points saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _controllers.forEach((liftName, controller) {
        final points = kLiftDefaultPointsMap[liftName] ?? 0;
        controller.text = points.toString();
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default values'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToLastSaved() {
    setState(() {
      _controllers.forEach((liftName, controller) {
        final points = _lastSavedPoints[liftName] ?? 0;
        controller.text = points.toString();
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to last saved values'),
        duration: Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lift Points'),
        centerTitle: true,
      ),
      body: Padding(
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
