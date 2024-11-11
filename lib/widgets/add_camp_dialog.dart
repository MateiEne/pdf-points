import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/utils/date_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/date_time_picker_widget.dart';

class AddCampDialog extends StatefulWidget {
  const AddCampDialog({super.key, this.campInfo});

  final ExcelCampInfo? campInfo;

  @override
  State<AddCampDialog> createState() => _AddCampDialogState();
}

class _AddCampDialogState extends State<AddCampDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  late String _name;

  @override
  void initState() {
    super.initState();

    _startDate = widget.campInfo?.startSkiDate?.subtract(const Duration(days: 1)) ?? DateTimeUtils.today();
    _endDate = widget.campInfo?.endSkiDate ?? _startDate.add(const Duration(days: kCampDaysLength - 1));
    _name = widget.campInfo?.name ?? "";
  }

  void _onStartDateChanged(DateTime? date) {
    if (date == null) {
      return;
    }

    safeSetState(() {
      _startDate = date;

      _endDate = _startDate.add(const Duration(days: kCampDaysLength - 1));
    });
  }

  void _onEndDateChanged(DateTime? date) {
    if (date == null) {
      return;
    }

    safeSetState(() {
      _endDate = date;
    });
  }

  Future<void> _onAddCamp() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    // TODO: save the camp to firebase
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  bool _validData() {
    return _name.isNotEmpty && _startDate.isBeforeOrEqual(_endDate);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add camp"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camp name
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Name"),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onChanged: (value) {
                  safeSetState(() {
                    _name = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Camp start date
              DateTimePickerWidget(
                leading: const Text("Start date:"),
                startDate: DateTime.now(),
                initialDate: _startDate,
                onChanged: _onStartDateChanged,
                showTime: false,
              ),

              // Camp end date
              DateTimePickerWidget(
                leading: const Text("End date:"),
                startDate: _startDate,
                initialDate: _endDate,
                onChanged: _onEndDateChanged,
                showTime: false,
              ),

              if (widget.campInfo?.participants != null) ...[
                const SizedBox(height: 12),
                Text("Participants: ${widget.campInfo!.participants.length}"),
              ],
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedAutoLoadingButton(
          style: ElevatedButton.styleFrom(backgroundColor: kAppSeedColor, foregroundColor: Colors.white),
          onPressed: _validData() ? _onAddCamp : null,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
