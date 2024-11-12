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
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  late DateTime _startDate;
  late DateTime _endDate;
  late String _name;
  String _password = "";
  String _confirmPassword = "";

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

    // TODO: save the camp to firebase:
    // FirebaseManager.instance.addCamp(
    //   name: _name,
    //   password: _password,
    //   startDate: _startDate,
    //   endDate: _endDate,
    //   participants: widget.campInfo?.participants ?? [],
    //   instructors: [],
    // );
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  bool _validName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return true;
  }

  bool _validPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return true;
  }

  bool _validConfirmPassword(String? value) {
    return value == _password;
  }

  bool _validData() {
    if (!_validName(_name)) {
      return false;
    }

    if (!_validPassword(_password)) {
      return false;
    }

    if (!_validConfirmPassword(_confirmPassword)) {
      return false;
    }

    if (_startDate.isAfter(_endDate)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add camp"),
      content: SingleChildScrollView(
        child: ConstrainedBox(
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
                    if (!_validName(value)) {
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

                const SizedBox(height: 4),

                // Camp password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible //
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        safeSetState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  enableSuggestions: true,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (!_validPassword(value)) {
                      return "Please enter a password";
                    }

                    return null;
                  },
                  onChanged: (value) {
                    safeSetState(() {
                      _password = value;
                    });

                    if (_confirmPassword.isNotEmpty) {
                      _confirmPasswordFieldKey.currentState?.validate();
                    }
                  },
                ),

                const SizedBox(height: 4),

                // Camp password again
                TextFormField(
                  key: _confirmPasswordFieldKey,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible //
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        safeSetState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  enableSuggestions: true,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (!_validConfirmPassword(value)) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _confirmPasswordFieldKey.currentState?.validate();

                    safeSetState(() {
                      _confirmPassword = value;
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
