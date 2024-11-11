import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/screens/camp_screen.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/platform_file_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();
  bool _loadingFab = false;

  bool _isSuperUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  void _checkSuperUser() async {
    safeSetState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    // TODO: add user model class
    final userData = await FirebaseFirestore.instance //
        .collection('users')
        .doc(user.uid)
        .get();

    // TODO: check user.isSuperuser once the user model is added
    if (userData.data()!['is_super'] != null) {
      safeSetState(() {
        _isSuperUser = true;
        _isLoading = false;
      });

      return;
    }

    safeSetState(() {
      _isSuperUser = false;
      _isLoading = false;
    });
  }

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
      // TODO: get the camp object from the excel file
      var camp = await PdfPointsExelParser.getCampInfoFromExcel(fileBytes);

      if (!mounted) return;

      showDialog(context: context, builder: (_) => AddCampDialog(campInfo: camp));
    } catch (e) {
      if (mounted) {
        context.showToast(e.toString(), negative: true);
      }
    }

    stopFabLoading();
  }

  void _onManuallyAddCamp({ExcelCampInfo? campInfo}) {
    // close the fab
    _fabKey.currentState?.toggle();

    showDialog(context: context, builder: (_) => AddCampDialog(campInfo: campInfo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const Drawer(),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Coming soon ... ${_isSuperUser ? 'super user' : 'normal user'}'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CampScreen()),
                      );
                    },
                    child: const Text("Go to camp"),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
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
            onPressed: _onManuallyAddCamp,
            label: const Text("Manually"),
            icon: const Icon(Icons.edit),
          ),
          FloatingActionButton.extended(
            onPressed: _onAddCampFromExcel,
            label: const Text("From Excel"),
            icon: const Icon(Icons.file_open),
          ),
        ],
      ),
    );
  }
}
