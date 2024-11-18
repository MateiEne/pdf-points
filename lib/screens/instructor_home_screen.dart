import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/modals/search_participant.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/ski_group/no_ski_group.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key, required this.instructor});

  final Participant instructor;

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  bool _isLoading = true;
  SkiGroup? _skiGroup;

  @override
  void initState() {
    super.initState();

    _fetchGroup(widget.instructor.id);
  }

  Future<void> _fetchGroup(String uid) async {
    safeSetState(() {
      _isLoading = true;
    });

    // TODO: Check if this instructor has a group
    await Future.delayed(const Duration(milliseconds: 500));

    safeSetState(() {
      _isLoading = false;
      // _skiGroup = null;
      _skiGroup = SkiGroup(name: "Abi", instructor: widget.instructor);
    });
  }

  void _onAddSkiGroup(SkiGroup skiGroup) {
    safeSetState(() {
      _skiGroup = skiGroup;
    });
  }

  Widget _showGroupScreen() {
    SkiGroup? skiGroup = _skiGroup;

    if (skiGroup == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (skiGroup.participants.isEmpty) ...[
          // top padding
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

          // Title
          Text(
            "You don't have students yet.",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 48),

          // Instructions to add ski group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add all your students to this group using the button below.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Add ski group button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            maximumSize: const Size(double.infinity, 56),
          ),
          onPressed: _openParticipantsSearchModal,
          child: const Center(
            child: Text('Add Student'),
          ),
        ),
      ],
    );

    // DropDownState(
    //   DropDown(
    //     bottomSheetTitle: const Text(
    //       kCities,
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 20.0,
    //       ),
    //     ),
    //     submitButtonChild: const Text(
    //       'Done',
    //       style: TextStyle(
    //         fontSize: 16,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     data: widget.cities ?? [],
    //     onSelected: (List<dynamic> selectedList) {
    //       List<String> list = [];
    //       for(var item in selectedList) {
    //         if(item is SelectedListItem) {
    //           list.add(item.name);
    //         }
    //       }
    //       showSnackBar(list.toString());
    //     },
    //     enableMultipleSelection: true,
    //   ),
    // ).showModal(context);
  }

  Future<void> _onAddParticipantToSkiGroup(BuildContext modalSheetContext, Participant participant) async {
    print(participant);
  }

  void _openParticipantsSearchModal() {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   useRootNavigator: true,
    //   useSafeArea: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
    //   ),
    //   showDragHandle: true,
    //   constraints: BoxConstraints.loose(
    //     Size.fromHeight(MediaQuery.of(context).size.height * 0.8),
    //   ),
    //   builder: (context) {
    //     return SearchParticipantContent(onSelected: (_) {});
    //   },
    // );

    SearchParticipantModal.show(
      context: context,
      onSelected: _onAddParticipantToSkiGroup,
      showNavBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AutoSizeText(
          _skiGroup == null //
              ? widget.instructor.shortName
              : _skiGroup!.name,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: _skiGroup == null //
                    ? NoSkiGroup(instructor: widget.instructor, onAddSkiGroup: _onAddSkiGroup)
                    : _showGroupScreen(),
              ),
      ),
    );
  }
}
