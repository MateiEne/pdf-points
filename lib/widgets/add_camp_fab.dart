import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/platform_file_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_content.dart';
import 'package:pdf_points/widgets/add_camp_image_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddCampFab extends StatefulWidget {
  /// The location of the ExpandableFab on the screen.
  static final FloatingActionButtonLocation location = ExpandableFab.location;

  const AddCampFab({super.key});

  @override
  State<AddCampFab> createState() => _AddCampFabState();
}

class _AddCampFabState extends State<AddCampFab> {
  final _fabKey = GlobalKey<ExpandableFabState>();
  bool _loadingFab = false;

  Future<void> _onAddCampFromExcel() async {
    void stopFabLoading() {
      safeSetState(() {
        _loadingFab = false;
      });
    }

    // close the fab
    _fabKey.currentState?.toggle();

    // start fab loading animation
    safeSetState(() {
      _loadingFab = true;
    });

    // open file picker
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (!mounted || pickedFile == null) {
      // no file picked => stop fab loading animation
      stopFabLoading();
      return;
    }

    if (pickedFile.files.isEmpty) {
      // empty file selection => stop fab loading animation
      stopFabLoading();
      context.showToast("Empty selection", negative: true);
      return;
    }

    final fileBytes = pickedFile.files.first.getBytes();
    if (fileBytes == null) {
      // no file bytes => stop fab loading animation
      stopFabLoading();
      context.showToast("Could not open the file", negative: true);
      return;
    }

    try {
      var campInfo = await PdfPointsExelParser.getCampInfoFromExcel(fileBytes);

      if (!mounted) return;

      // open the modal to add the necessary camp data
      _openModal(campInfo: campInfo);
    } catch (e) {
      if (mounted) {
        context.showToast(e.toString(), negative: true);
      }
    }

    stopFabLoading();
  }

  void _onManuallyAddCamp() {
    // close the fab
    _fabKey.currentState?.toggle();

    // open the modal to add the necessary camp data
    _openModal();
  }

  void _openModal({ExcelCampInfo? campInfo}) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Add Camp',
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
            child: AddCampContentWidget(
              campInfo: campInfo,
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
              sliver: AddCampImageContent(
                crossAxisCount: 3,
                defaultImages: kDefaultCampImages,
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
    return ExpandableFab(
      key: _fabKey,
      // type: ExpandableFabType.up,
      distance: 75,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.5),
        blur: 3,
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: _loadingFab
            ? const Padding(
                padding: EdgeInsets.all(14.0),
                child: CircularProgressIndicator(),
              )
            : const Icon(Icons.add),
      ),
      afterOpen: () {
        if (_loadingFab) {
          // close the fab since is in the loading state
          _fabKey.currentState?.toggle();
        }
      },
      children: [
        FloatingActionButton.extended(
          heroTag: 'manually',
          onPressed: _onManuallyAddCamp,
          label: const Text("Manually"),
          icon: const Icon(Icons.edit),
        ),
        FloatingActionButton.extended(
          heroTag: 'from_excel',
          onPressed: _onAddCampFromExcel,
          label: const Text("From Excel"),
          icon: const Icon(Icons.file_open),
        ),
      ],
    );
  }
}
