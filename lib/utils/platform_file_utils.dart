import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

extension PlatformFileUtils on PlatformFile {
  Uint8List? getBytes() {
    if (kIsWeb) {
      return bytes;
    }

    if (path == null) {
      return null;
    }

    return File(path!).readAsBytesSync();
  }
}
