import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class AddSkiGroupContentWidget extends StatefulWidget {
  const AddSkiGroupContentWidget({
    super.key,
    this.defaultName,
    this.onAddImage,
    required this.onAddSkiCamp,
  });

  final String? defaultName;
  final Future<Uint8List?> Function()? onAddImage;
  final Future<void> Function(String name) onAddSkiCamp;

  @override
  State<AddSkiGroupContentWidget> createState() => _AddSkiGroupContentWidgetState();
}

class _AddSkiGroupContentWidgetState extends State<AddSkiGroupContentWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  String _name = "";
  Uint8List? _image;

  @override
  void initState() {
    super.initState();

    _name = widget.defaultName ?? "";
    _nameController.text = _name;

    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    safeSetState(() {
      _name = _nameController.text.trim();
    });
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

    FocusManager.instance.primaryFocus?.unfocus();

    await widget.onAddSkiCamp(_name);
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
          // ConstrainedBox(
          //   constraints: const BoxConstraints(
          //     maxHeight: 300,
          //   ),
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       if (_image != null)
          //         AnimatedSizeAndFade.showHide(
          //           show: true,
          //           child: Image(
          //             image: MemoryImage(_image!),
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //       IconButton(
          //         icon: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white.withOpacity(0.6),
          //             borderRadius: BorderRadius.circular(50),
          //           ),
          //           width: 100,
          //           height: 100,
          //           child: const Icon(
          //             Icons.add_a_photo_rounded,
          //             size: 32,
          //           ),
          //         ),
          //         onPressed: _onAddImage,
          //       ),
          //     ],
          //   ),
          // ),
          //
          // const SizedBox(height: 4),

          // Camp name
          TextFormField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Name",
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _nameController.clear,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (!_validName(value)) {
                return "Please enter a name";
              }
              return null;
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
              child: Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
