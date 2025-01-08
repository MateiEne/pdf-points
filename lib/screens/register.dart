import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/screens/instructor_home.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/user_image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _firstNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _lastNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();

  String _email = '';
  String _password = '';
  String _confirmPassword = "";
  String _firstName = '';
  String _lastName = '';
  String _phone = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  File? _selectedImage;

  Future<void> _onRegister() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    try {
      Instructor? instructor = await FirebaseManager.instance.createInstructorUser(
        email: _email,
        password: _password,
        firstName: _firstName,
        lastName: _lastName,
        phone: _phone,
        profileImage: _selectedImage,
      );

      if (!mounted || instructor == null) return;

      // navigate to instructor's home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => InstructorHomeScreen(instructor: instructor)),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed. Please try again.'),
        ),
      );
    }
  }

  bool _validEmail(String? value) {
    if (value == null || value.isEmpty || !EmailValidator.validate(value)) {
      return false;
    }

    return true;
  }

  bool _validPassword(String? value) {
    if (value == null || value.isEmpty || value.length < kPasswordLength) {
      return false;
    }

    return true;
  }

  bool _validConfirmPassword(String? value) {
    return value == _password;
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
    if (!_validEmail(_email) ||
        !_validPassword(_password) ||
        !_validConfirmPassword(_confirmPassword) ||
        !_validName(_firstName) ||
        !_validName(_lastName) ||
        !_validPhone(_phone)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),

                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  width: 200,
                  child: Image.asset('assets/images/logo.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Image
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),

                            // Email Address
                            TextFormField(
                              key: _emailFieldKey,
                              decoration: const InputDecoration(labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (!_validEmail(value)) {
                                  return 'Please enter a valid email address';
                                }

                                return null;
                              },
                              onChanged: (value) {
                                _emailFieldKey.currentState?.validate();
                                safeSetState(() {
                                  _email = value;
                                });
                              },
                            ),

                            // Password
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
                                  return "Password must be at least 6 characters long";
                                }

                                return null;
                              },
                              onChanged: (value) {
                                _passwordFieldKey.currentState?.validate();
                                safeSetState(() {
                                  _password = value;
                                });

                                if (_confirmPassword.isNotEmpty) {
                                  _confirmPasswordFieldKey.currentState?.validate();
                                }
                              },
                            ),

                            // Password again
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

                            // First Name
                            TextFormField(
                              key: _firstNameFieldKey,
                              decoration: const InputDecoration(labelText: "First Name"),
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (!_validName(value)) {
                                  return "Please enter a name";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _firstNameFieldKey.currentState?.validate();

                                safeSetState(() {
                                  _firstName = value.trim();
                                });
                              },
                            ),

                            // Last Name
                            TextFormField(
                              key: _lastNameFieldKey,
                              decoration: const InputDecoration(labelText: "Last Name"),
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (!_validName(value)) {
                                  return "Please enter a name";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _lastNameFieldKey.currentState?.validate();

                                safeSetState(() {
                                  _lastName = value.trim();
                                });
                              },
                            ),

                            // Phone
                            TextFormField(
                              key: _phoneFieldKey,
                              decoration: const InputDecoration(labelText: "Phone number"),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (!_validPhone(value)) {
                                  return "Please enter a phone number";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _phoneFieldKey.currentState?.validate();

                                safeSetState(() {
                                  _phone = value.trim();
                                });
                              },
                            ),

                            const SizedBox(height: 24),

                            // Register Button
                            ElevatedAutoLoadingButton(
                              onPressed: _validData() ? _onRegister : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Create an account Button
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('I already have an account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
