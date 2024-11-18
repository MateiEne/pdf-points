import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/widgets/search_participant_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SearchParticipantModal {
  static Future<void> show({
    required BuildContext context,
    required void Function(BuildContext context, Participant participant) onSelected,
    bool showNavBar = true,
  }) {
    return WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          navBarHeight: showNavBar ? null : 1,
          topBarTitle: showNavBar
              ? Text(
                  'Search Participant',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                )
              : null,
          isTopBarLayerAlwaysVisible: showNavBar,
          trailingNavBarWidget: showNavBar
              ? IconButton(
                  padding: const EdgeInsets.all(16.0),
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(modalSheetContext).pop,
                )
              : null,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size.fromHeight(MediaQuery.of(context).size.height * 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchParticipantContent(
                  onSelected: (participant) => onSelected(modalSheetContext, participant),
                ),
              ),
            ),
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
}
