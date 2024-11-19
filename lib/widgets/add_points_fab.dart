import 'package:flutter/material.dart';

class AddPointsFab extends StatefulWidget {
  /// The location of the ExpandableFab on the screen.
  static const FloatingActionButtonLocation location = FloatingActionButtonLocation.endFloat;

  const AddPointsFab({super.key});

  @override
  State<AddPointsFab> createState() => _AddPointsFabState();
}

class _AddPointsFabState extends State<AddPointsFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      label: const Text("Add Points"),
      icon: const Icon(Icons.add),
    );
  }
}
