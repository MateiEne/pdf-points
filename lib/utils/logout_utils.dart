import 'package:flutter/material.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/pages/login.dart';

class LogoutUtils {
  /// Shows a confirmation dialog before logging out
  /// Returns true if the user confirmed and logged out, false otherwise
  static Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseManager.instance.signOut();
      
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return true;
    }

    return false;
  }
}