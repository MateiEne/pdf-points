import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/modals/add_camp.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/platform_file_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';

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
      print("campInfo: $campInfo");

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
    AddCampModal.show(context: context, campInfo: campInfo);
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
