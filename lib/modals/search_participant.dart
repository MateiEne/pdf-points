import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/widgets/search_participant_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SearchParticipantModal {
  static Future<Participant?> show({
    required BuildContext context,
    required String campId,
    bool showNavBar = true,
    String? excludeGroupId,
  }) {
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

    return WoltModalSheet.show<Participant?>(
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
                  campId: campId,
                  excludeGroupId: excludeGroupId,
                  addParticipantIfNotFound: true,
                  onSelected: (participant) {
                    Navigator.of(modalSheetContext).pop(participant);
                  },
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
