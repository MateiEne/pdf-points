import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class EnrollInstructorToCampContentWidget extends StatefulWidget {
  const EnrollInstructorToCampContentWidget({
    super.key,
    required this.instructor,
    required this.onEnrolled,
  });

  final Instructor instructor;
  final void Function(Camp camp) onEnrolled;

  @override
  State<EnrollInstructorToCampContentWidget> createState() => _EnrollInstructorToCampContentWidgetState();
}

class _EnrollInstructorToCampContentWidgetState extends State<EnrollInstructorToCampContentWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  String _password = "";

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    safeSetState(() {
      _password = _passwordController.text.trim();
    });
  }

  Future<void> _onEnroll() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    //FocusManager.instance.primaryFocus?.unfocus();

    Camp? camp = await FirebaseManager.instance.enrollInstructorToCamp(
      password: _password,
      instructor: widget.instructor,
    );

    if (!mounted) return;

    if (camp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid password"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    widget.onEnrolled(camp);
  }

  bool _validPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
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
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: "Camp Password",
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
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (!_validPassword(value)) {
                return "Please enter a password";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Enroll button
          ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _password.isNotEmpty ? _onEnroll : null,
            child: const Center(
              child: Text('Enroll'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
