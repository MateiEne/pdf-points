import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/modals/open_pictures.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/date_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/date_time_picker_widget.dart';

class AddCampContentWidget extends StatefulWidget {
  const AddCampContentWidget({
    super.key,
    this.campInfo,
    this.onCampAdded,
  });

  final ExcelCampInfo? campInfo;
  final void Function(Camp camp)? onCampAdded;

  @override
  State<AddCampContentWidget> createState() => _AddCampContentWidgetState();
}

class _AddCampContentWidgetState extends State<AddCampContentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  late DateTime _startDate;
  late DateTime _endDate;
  late String _name;
  String _password = "";
  String _confirmPassword = "";

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordAlreadyUsedErrorMessage;

  Uint8List? _image;

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

  Future<void> _onAddImage() async {
    var image = await OpenPicturesModal.show<Uint8List?>(
      context: context,
      title: "Add Picture",
    );
    if (image == null) {
      return;
    }

    safeSetState(() {
      _image = image;
    });
  }

  Future<void> _onAddCamp() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    // check if a camp with the same password already exists
    if (await FirebaseManager.instance.checkIfCampExistWithPassword(password: _password)) {
      _confirmPasswordController.clear();
      _passwordFocusNode.requestFocus();
      safeSetState(() {
        _passwordAlreadyUsedErrorMessage = "Password already used. Please choose another one.";
      });
      return;
    }

    var camp = await FirebaseManager.instance.addCamp(
      name: _name,
      password: _password,
      startDate: _startDate,
      endDate: _endDate,
      participants: widget.campInfo?.participants ?? [],
      image: _image,
    );

    widget.onCampAdded?.call(camp);
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Camp Image
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_image != null)
                  AnimatedSizeAndFade.showHide(
                    show: true,
                    child: Image(
                      image: MemoryImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 100,
                    height: 100,
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 32,
                    ),
                  ),
                  onPressed: _onAddImage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

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
                _name = value.trim();
              });
            },
          ),

          const SizedBox(height: 4),

          // Camp password
          TextFormField(
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordAlreadyUsedErrorMessage,
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
                _passwordAlreadyUsedErrorMessage = null;
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
            controller: _confirmPasswordController,
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
            const SizedBox(height: 4),
            Text("Participants: ${widget.campInfo!.participants.length}"),
          ],

          const SizedBox(height: 16),

          ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _validData() ? _onAddCamp : null,
            child: const Center(
              child: Text('Add Camp'),
            ),
          ),
        ],
      ),
    );
  }
}
