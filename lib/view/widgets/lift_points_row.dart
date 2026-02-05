import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';

class LiftPointsRow extends StatelessWidget {
  const LiftPointsRow({
    super.key,
    required this.liftName,
    required this.liftInfo,
    required this.isSelected,
    required this.isModified,
    required this.controller,
    required this.onChanged,
    required this.onDecrement,
    required this.onIncrement,
    required this.usedLiftNames,
  });

  final String liftName;
  final LiftInfo? liftInfo;
  final bool isSelected;
  final bool isModified;
  final TextEditingController controller;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Set<String> usedLiftNames;

  String _getLiftType(String liftName) {
    if (kCableCars.contains(liftName)) return kCableCar;
    if (kGondolas.contains(liftName)) return kGondola;
    if (kChairlifts.contains(liftName)) return kChairlift;
    if (kSkilifts.contains(liftName)) return kSkilift;
    return 'Unknown';
  }

  String _getLiftIcon(String liftType) {
    switch (liftType) {
      case kCableCar:
        return kCableCarIcon;
      case kGondola:
        return kGondolaIcon;
      case kChairlift:
        return kChairliftIcon;
      case kSkilift:
        return kSkiliftIcon;
      default:
        return kSkiliftIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasModificationInfo = liftInfo != null;
    final isUpdatedToday = liftInfo?.isFromToday() ?? false;
    final isUsedToday = usedLiftNames.contains(liftName);

    Color? cardColor;
    if (isUpdatedToday) {
      cardColor = Colors.green.shade100;
    } else if (isUsedToday) {
      cardColor = Colors.red.shade100;
    }

    return Card(
      elevation: 2,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              fillColor: isModified ? MaterialStateProperty.all(kAppSeedColor) : null,
              onChanged: onChanged,
            ),
            Image.asset(
              _getLiftIcon(_getLiftType(liftName)),
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liftName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (hasModificationInfo) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatModificationInfo(liftInfo!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red.shade900,
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
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
                IconButton(
                  onPressed: onIncrement,
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

  String _formatModificationInfo(LiftInfo liftInfo) {
    final now = DateTime.now();
    final modifiedAt = liftInfo.modifiedAt;
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
}
