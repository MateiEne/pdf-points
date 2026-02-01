
import 'package:flutter/material.dart';

extension SnackBarExtension on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarError(
    String errorMessage, {
    Duration duration = const Duration(seconds: 3),
  }) {
    clearSnackBars(); // Clear any existing snack bars before showing a new one
    return showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Text(errorMessage),
      duration: duration,
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarSuccess(
    String successMessage, {
    Duration duration = const Duration(seconds: 3),
  }) {
    clearSnackBars(); // Clear any existing snack bars before showing a new one
    return showSnackBar(SnackBar(
      // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      content: Text(successMessage),
      duration: duration,
    ));
  }
}
