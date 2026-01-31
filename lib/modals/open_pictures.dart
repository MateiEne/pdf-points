import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/view/widgets/image_picker_with_defaults.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class OpenPicturesModal {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
  }) {
    return WoltModalSheet.show<T>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        SliverWoltModalSheetPage(
          topBarTitle: Text(
            title ?? 'Add Picture',
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
    );
  }
}
