import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:pdf_points/view/widgets/lift_points_row.dart';

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

  void _incrementPoints() {
    setState(() {
      int currentValue = int.tryParse(_controller.text) ?? 0;
      _controller.text = (currentValue + 1).toString();
    });
  }

  void _decrementPoints() {
    setState(() {
      int currentValue = int.tryParse(_controller.text) ?? 0;
      if (currentValue > 0) {
        _controller.text = (currentValue - 1).toString();
      }
    });
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiftPointsRow(
            liftName: widget.liftInfo.name,
            liftSubtitle: widget.liftInfo.getStatusInfo(),
            isSelected: false,
            isModified: int.tryParse(_controller.text) != widget.liftInfo.points,
            isUpdatedToday: false,
            isUsedToday: false,
            showCheckbox: false,
            isLarge: true,
            controller: _controller,
            onDecrement: _decrementPoints,
            onIncrement: _incrementPoints,
          ),

          const SizedBox(height: 16),
          
          ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _onUpdatePoints,
            child: const Center(
              child: Text('Update Points'),
            ),
          ),
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
