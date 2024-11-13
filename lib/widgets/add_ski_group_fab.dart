import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/widgets/add_ski_group_content.dart';
import 'package:pdf_points/widgets/image_picker_with_defaults.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddSkiGroupFab extends StatefulWidget {
  const AddSkiGroupFab({super.key, required this.instructorId});

  final String instructorId;

  @override
  State<AddSkiGroupFab> createState() => _AddSkiGroupFabState();
}

class _AddSkiGroupFabState extends State<AddSkiGroupFab> {
  void _onAddSkiGroup() {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AddSkiGroupContentWidget(
              onAddImage: _openPicturesModal,
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

  Future<Uint8List?> _openPicturesModal() async {
    return WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        SliverWoltModalSheetPage(
          topBarTitle: Text(
            'Add Picture',
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
          mainContentSliversBuilder: (context) => [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: ImagePickerWithDefaults(
                crossAxisCount: 3,
                assetsImages: kDefaultCampImages,
                onImageSelected: (Uint8List image) {
                  Navigator.of(modalSheetContext).pop(image);
                },
              ),
            ),
          ],
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
    ).then((value) => value as Uint8List?);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _onAddSkiGroup,
      child: const Icon(Icons.add),
    );
  }
}
