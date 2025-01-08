import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/utils/string_utils.dart';

class AddOrUpdateParticipantContentWidget extends StatefulWidget {
  const AddOrUpdateParticipantContentWidget({
    super.key,
    required this.campId,
    this.onAddParticipantAdded,
    this.defaultFirstName,
    this.defaultLastName,
    this.defaultPhone,
    this.participantId,
  });

  final String campId;
  final void Function(Participant participant)? onAddParticipantAdded;
  final String? defaultFirstName;
  final String? defaultLastName;
  final String? defaultPhone;
  final String? participantId;

  @override
  State<AddOrUpdateParticipantContentWidget> createState() => _AddOrUpdateParticipantContentWidgetState();
}

class _AddOrUpdateParticipantContentWidgetState extends State<AddOrUpdateParticipantContentWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _firstName = "";
  String _lastName = "";
  String _phone = "";

  @override
  void initState() {
    super.initState();

    _firstName = widget.defaultFirstName?.capitalize() ?? "";
    _firstNameController.text = _firstName;

    _lastName = widget.defaultLastName?.capitalize() ?? "";
    _lastNameController.text = _lastName;

    _phone = widget.defaultPhone ?? "";
    _phoneController.text = _phone;

    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onFirstNameChanged() {
    safeSetState(() {
      _firstName = _firstNameController.text.trim();
    });
  }

  void _onLastNameChanged() {
    safeSetState(() {
      _lastName = _lastNameController.text.trim();
    });
  }

  void _onPhoneChanged() {
    safeSetState(() {
      _phone = _phoneController.text.trim();
    });
  }

  Future<void> _onAddParticipant() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    // FocusManager.instance.primaryFocus?.unfocus();
    var participant = await FirebaseManager.instance.addParticipantToCamp(
      campId: widget.campId,
      id: widget.participantId,
      firstName: _firstName,
      lastName: _lastName,
      phone: _phone,
    );

    if (!mounted) return;

    widget.onAddParticipantAdded?.call(participant);
  }

  bool _validName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return true;
  }

  bool _validPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return true;
  }

  bool _validData() {
    if (!_validName(_firstName) || !_validName(_lastName) || !_validPhone(_phone)) {
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
          // First name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  autofocus: _firstNameController.text.isEmpty,
                  decoration: InputDecoration(
                    labelText: "First Name",
                    suffixIcon: _firstNameController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _firstNameController.clear,
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (!_validName(value)) {
                      return "Please enter a name";
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  var temp = _firstNameController.text;
                  _firstNameController.text = _lastNameController.text;
                  _lastNameController.text = temp;
                },
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ],
          ),

          // Last name
          TextFormField(
            controller: _lastNameController,
            autofocus: _lastNameController.text.isEmpty,
            decoration: InputDecoration(
              labelText: "Last Name",
              suffixIcon: _lastNameController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _lastNameController.clear,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (!_validName(value)) {
                return "Please enter a name";
              }
              return null;
            },
          ),

          // phone
          TextFormField(
            controller: _phoneController,
            autofocus: _phoneController.text.isEmpty,
            decoration: InputDecoration(
              labelText: "Phone number",
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _phoneController.clear,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (!_validPhone(value)) {
                return "Please enter a phone number";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _validData() ? _onAddParticipant : null,
            child: const Center(
              child: Text('Add Participant'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }
}
