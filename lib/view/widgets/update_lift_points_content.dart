import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';

class UpdateLiftPointsContent extends StatefulWidget {
  const UpdateLiftPointsContent({
    super.key,
    required this.liftInfo,
    required this.onPointsUpdated,
    required this.onCancel,
  });

  final LiftInfo liftInfo;
  final VoidCallback onPointsUpdated;
  final VoidCallback onCancel;

  @override
  State<UpdateLiftPointsContent> createState() => _UpdateLiftPointsContentState();
}

class _UpdateLiftPointsContentState extends State<UpdateLiftPointsContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.liftInfo.points).toString(),
    );
  }

  Future<void> _onUpdatePoints() async {
    final points = int.tryParse(_controller.text);
    if (points == null) {
      return;
    }

    await FirebaseManager.instance.addLiftValuePoints(
      liftName: widget.liftInfo.name,
      points: points,
      type: kLiftTypeMap[widget.liftInfo.name] ?? 'Unknown',
      modifiedAt: DateTime.now(),
      modifiedBy: widget.liftInfo.modifiedBy,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBarSuccess("Points updated!");
      widget.onPointsUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use lift_points_row widget
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _onUpdatePoints,
                child: const Text("Update"),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
