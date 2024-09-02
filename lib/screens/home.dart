import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/participants_exel_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSuperUser = false;

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  void _checkSuperUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance //
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.data()!['is_super'] != null) {
      setState(() {
        _isSuperUser = true;
      });

      return;
    }

    setState(() {
      _isSuperUser = false;
    });
  }

  Future<void> _selectFile() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile == null) {
      if (context.mounted) {
        context.showToast("Could not open the file", negative: true);
      }
      return;
    }

    var path = pickedFile.files.first.path;
    if (path == null) {
      if (context.mounted) {
        context.showToast("Could not open the file", negative: true);
      }
      return;
    }

    try {
      var participants = await ParticipantsExelParser.parseParticipantsExcel(path);
    } on ExcelParseException catch (e) {
      if (context.mounted) {
        context.showToast(e.message, negative: true);
      }
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Coming soon ... ${_isSuperUser ? 'super user' : 'normal user'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectFile,
              child: const Text("Import participants excel"),
            )
          ],
        ),
      ),
    );
  }
}
