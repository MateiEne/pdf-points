import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class AddSkiGroupContentWidget extends StatefulWidget {
  const AddSkiGroupContentWidget({
    super.key,
    this.onAddImage,
  });

  final Future<Uint8List?> Function()? onAddImage;

  @override
  State<AddSkiGroupContentWidget> createState() => _AddSkiGroupContentWidgetState();
}

class _AddSkiGroupContentWidgetState extends State<AddSkiGroupContentWidget> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onAddImage() async {
    if (widget.onAddImage == null) {
      await _openGallery();
      return;
    }

    var image = await widget.onAddImage!();
    if (image == null) {
      return;
    }

    safeSetState(() {
      _image = image;
    });

    return;
  }

  Future<void> _openGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    var data = await pickedFile.readAsBytes();

    safeSetState(() {
      _image = data;
    });
  }

  Future<void> _onAddSkiGroup() async {
    var valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    // TODO: save the group to firebase:
    // FirebaseManager.instance.addSkiGroup(
    //   name: _name,
    //   image: _image,
    //   instructor: _instructor,
    // );
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  bool _validName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return true;
  }

  bool _validData() {
    if (!_validName(_name)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Camp Image
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_image != null)
                  AnimatedSizeAndFade.showHide(
                    show: true,
                    child: Image(
                      image: MemoryImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 100,
                    height: 100,
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 32,
                    ),
                  ),
                  onPressed: _onAddImage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Camp name
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: "Name"),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (!_validName(value)) {
                return "Please enter a name";
              }
              return null;
            },
            onChanged: (value) {
              safeSetState(() {
                _name = value;
              });
            },
          ),

          const SizedBox(height: 16),

          ElevatedAutoLoadingButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 56),
              maximumSize: const Size(double.maxFinite, 56),
            ),
            onPressed: _validData() ? _onAddSkiGroup : null,
            child: const Center(
              child: Text('Add Group'),
            ),
          ),
        ],
      ),
    );
  }
}
