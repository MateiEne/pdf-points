import 'package:flutter/material.dart';
import 'package:pdf_points/data/lift_user.dart';

class LiftUsersSelectorWidget extends StatefulWidget {
  const LiftUsersSelectorWidget({
    super.key,
    required this.onSelectedLiftUsersChanged,
    required this.liftUsers,
    this.selectedLiftUsers = const [],
  });

  final void Function(List<LiftUser> selectedLiftUsers) onSelectedLiftUsersChanged;
  final List<LiftUser> liftUsers;
  final List<LiftUser> selectedLiftUsers;

  @override
  State<LiftUsersSelectorWidget> createState() => _LiftUsersSelectorWidgetState();
}

class _LiftUsersSelectorWidgetState extends State<LiftUsersSelectorWidget> {
  final List<LiftUser> _selectedLiftUsers = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectedLiftUsers.addAll(widget.selectedLiftUsers);
  }

  void _onSelectedStudentChanged(LiftUser liftUser, bool selected) {
    setState(() {
      if (selected) {
        _selectedLiftUsers.add(liftUser);
      } else {
        _selectedLiftUsers.removeWhere((s) => s.id == liftUser.id);
      }
    });

    widget.onSelectedLiftUsersChanged(_selectedLiftUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        // use shrinkWrap: true since the listview has few items
        shrinkWrap: true,
        controller: _scrollController,
        padding: const EdgeInsets.all(0),
        itemCount: widget.liftUsers.length,
        itemBuilder: (context, index) {
          bool selected = _selectedLiftUsers.any((s) => s.id == widget.liftUsers[index].id);

          return CheckboxListTile(
            title: Text(
              widget.liftUsers[index].fullName,
              style: selected //
                  ? const TextStyle(fontWeight: FontWeight.w600)
                  : null,
            ),
            value: selected,
            onChanged: (value) {
              if (value == null) return;

              _onSelectedStudentChanged(widget.liftUsers[index], value);
            },
          );
        },
      ),
    );
  }
}
