import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/widgets/lifts_selector_widget.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddPointsFab extends StatefulWidget {
  /// The location of the ExpandableFab on the screen.
  static const FloatingActionButtonLocation location = FloatingActionButtonLocation.endFloat;

  const AddPointsFab({super.key});

  @override
  State<AddPointsFab> createState() => _AddPointsFabState();
}

class _AddPointsFabState extends State<AddPointsFab> {

  void _openAddPointsDialog() {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBarTitle: Text(
            'Add Lift Points',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(modalSheetContext).pop();
            },
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LiftsSelectorWidget(
              onLiftSelected: (String lift) {
                WoltModalSheet.of(modalSheetContext).showNext();
              },
            ),
          ),
        ),

        WoltModalSheetPage(
          topBarTitle: Text(
            'Add Lift Points',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(modalSheetContext).pop();
            },
          ),
          leadingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: WoltModalSheet.of(modalSheetContext).showPrevious,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 200,
              color: Colors.red,
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        return const WoltDialogType();

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

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _openAddPointsDialog,
      label: const Text("Add Points"),
      icon: const Icon(Icons.add),
    );
  }
}
