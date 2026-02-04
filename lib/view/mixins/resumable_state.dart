import 'package:flutter/material.dart';

/// Mixin for state classes that need to perform an action when the screen is "resumed" or "revealed" again.
///
/// This is particularly useful in scenarios like `IndexedStack` where the widget state is preserved
/// but `initState` is not called again when switching back to the tab.
mixin ResumableState<T extends StatefulWidget> on State<T> {
  /// Called when the screen becomes visible/active again.
  /// Implementations should usually re-fetch data or refresh the UI.
  void onResume();
}
