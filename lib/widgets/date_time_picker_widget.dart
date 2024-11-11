import 'package:flutter/material.dart';
import 'package:pdf_points/utils/date_utils.dart';

class DateTimePickerWidget extends StatelessWidget {
  const DateTimePickerWidget({
    super.key,
    required this.startDate,
    required this.onChanged,
    this.showTime = true,
    this.leading,
    this.initialDate,
  });

  final DateTime startDate;
  final ValueChanged<DateTime> onChanged;
  final bool showTime;
  final Widget? leading;
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leading != null) leading!,
        TextButton(
          onPressed: () {
            showDatePicker(context: context, firstDate: startDate, lastDate: DateTime(2129), initialDate: initialDate ?? startDate)
                .then(
              (DateTime? newDate) {
                if (newDate != null) {
                  onChanged(newDate);
                }
              },
            );
          },
          child: Text((initialDate ?? startDate).toDateString()),
        ),
        if (showTime)
          TextButton(
            onPressed: () {
              showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startDate)).then(
                (TimeOfDay? newTime) {
                  if (newTime != null) {
                    onChanged(startDate.copyWith(hour: newTime.hour, minute: newTime.minute));
                  }
                },
              );
            },
            child: Text(
              startDate.toTimeString(),
            ),
          ),
      ],
    );
  }
}
