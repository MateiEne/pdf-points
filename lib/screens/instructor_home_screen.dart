import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_ski_group_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  bool _isLoading = true;
  SkiGroup? _group;

  @override
  void initState() {
    super.initState();

    _fetchGroup(widget.user.uid);
  }

  Future<void> _fetchGroup(String uid) async {
    safeSetState(() {
      _isLoading = true;
    });

    // TODO: Check if this instructor has a group
    await Future.delayed(const Duration(milliseconds: 500));

    safeSetState(() {
      _isLoading = false;
      _group = null;
      // _group = SkiGroup(name: "name", instructor: Participant(firstName: "Abi"));
    });
  }

  void _addSkiGroup() {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Add Group',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16.0),
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(modalSheetContext).pop,
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: AddSkiGroupContentWidget(),
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        final size = MediaQuery.sizeOf(context).width;

        return size < kPageWidthBreakpoint //
            ? const WoltBottomSheetType()
            : const WoltDialogType();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _noGroupScreen() {
    return Column(
      children: [
        // top padding
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

        // Title
        Text(
          "You don't have a group yet.",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 32),

        // Instructions to add ski group
        Text(
          '1. First add your group',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '2. Then add your participants',
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        const SizedBox(height: 24),

        // Add ski group button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            maximumSize: const Size(double.infinity, 56),
          ),
          onPressed: _addSkiGroup,
          child: const Center(
            child: Text('Add Your Group'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Instructor Name / Group Name',
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
                child: _group == null
                    ? _noGroupScreen()
                    : Column(
                        children: [
                          Text(
                            'Group Name: ${_group!.name}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
