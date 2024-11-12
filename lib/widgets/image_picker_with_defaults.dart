import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWithDefaults extends StatelessWidget {
  const ImagePickerWithDefaults({
    super.key,
    this.crossAxisCount = 3,
    this.assetsImages = const [],
    required this.onImageSelected,
  });

  final List<String> assetsImages;
  final int crossAxisCount;
  final void Function(Uint8List image) onImageSelected;

  Future<void> _openGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    var data = await pickedFile.readAsBytes();
    onImageSelected(data);
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext _, int index) {
          if (index == assetsImages.length) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
              onPressed: _openGallery,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 32,
                  ),
                  AutoSizeText('Gallery'),
                ],
              ),
            );
          }

          return Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: AssetImage(assetsImages[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              onTap: () async {
                final data = await rootBundle.load(assetsImages[index]);
                onImageSelected(data.buffer.asUint8List());
              },
            ),
          );
        },
        childCount: assetsImages.length + 1,
      ),
    );
  }
}
