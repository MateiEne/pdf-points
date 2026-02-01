import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/pdf_user.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:pdf_points/view/pages/instructor_main_screen.dart';
import 'package:pdf_points/view/pages/register.dart';
import 'package:pdf_points/view/pages/superuser_home.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  String _email = '';
  String _password = '';

  bool _isPasswordVisible = false;

  Future<dynamic> _onLogin() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    try {
      PdFUser? pdFUser = await FirebaseManager.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (!mounted || pdFUser == null) return;

      // navigate to the user screen
      final userHome = pdFUser is SuperUser
          ? SuperUserHomeScreen(superUser: pdFUser)
          : InstructorMainScreen(instructor: pdFUser as Instructor);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => userHome));
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBarError(
        error.message ?? 'Authentication failed. Please try again.'
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

  bool _validData() {
    if (!_validEmail(_email) || !_validPassword(_password)) {
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                              key: _passwordFieldKey,
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
                              },
                              onFieldSubmitted: (_) {
                                if (_validData()) {
                                  _onLogin();
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedAutoLoadingButton(
                              onPressed: _validData() ? _onLogin : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Create an account Button
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('Create an account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
