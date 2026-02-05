import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';

class LiftPointsRow extends StatelessWidget {
  const LiftPointsRow({
    super.key,
    required this.liftName,
    this.liftSubtitle,
    required this.isSelected,
    required this.isModified,
    required this.isUpdatedToday,
    required this.isUsedToday,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    this.onChanged,
    this.showCheckbox = true,
    this.isLarge = false,
  });

  final String liftName;
  final String? liftSubtitle;
  final bool isSelected;
  final bool isModified;
  final bool isUpdatedToday;
  final TextEditingController controller;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isUsedToday;
  final bool showCheckbox;
  final bool isLarge;

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
            showCheckbox
                ? Checkbox(
                    value: isSelected,
                    fillColor: isModified ? WidgetStateProperty.all(kAppSeedColor) : null,
                    onChanged: onChanged,
                  )
                : const SizedBox(width: 10),
            Image.asset(
              _getLiftIcon(_getLiftType(liftName)),
              width: isLarge ? 32 : 24,
              height: isLarge ? 32 : 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liftName,
                    style: isLarge
                        ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            )
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  if (liftSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      liftSubtitle!,
                      style: isLarge
                          ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              )
                          : Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: isLarge ? 6 : 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red.shade900,
                  iconSize: isLarge ? 32 : 24,
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
                    style: isLarge
                        ? Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                        : Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green.shade900,
                  iconSize: isLarge ? 32 : 24,
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
}
