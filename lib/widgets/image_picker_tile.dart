import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Compact camera/gallery picker with inline preview and compression.
/// Returns the selected XFile via onChanged. Keep your own layout; this is just a tile.
class ImagePickerTile extends StatefulWidget {
  final String title;
  final XFile? initial;
  final ValueChanged<XFile?> onChanged;
  final int imageQuality; // 0-100
  final double? maxWidth;

  const ImagePickerTile({
    Key? key,
    required this.title,
    required this.onChanged,
    this.initial,
    this.imageQuality = 85,
    this.maxWidth,
  }) : super(key: key);

  @override
  State<ImagePickerTile> createState() => _ImagePickerTileState();
}

class _ImagePickerTileState extends State<ImagePickerTile> {
  final _picker = ImagePicker();
  XFile? _file;

  @override
  void initState() {
    super.initState();
    _file = widget.initial;
  }

  Future<void> _pick(ImageSource source) async {
    final f = await _picker.pickImage(
      source: source,
      imageQuality: widget.imageQuality,
      maxWidth: widget.maxWidth ?? 1440,
    );
    if (f != null) {
      setState(() => _file = f);
      widget.onChanged(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trailing = _file == null
        ? const Icon(Icons.image_outlined)
        : SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _file!.path.startsWith('http')
            ? Image.network(_file!.path, fit: BoxFit.cover)
            : Image.file(File(_file!.path), fit: BoxFit.cover),
      ),
    );

    return ListTile(
      title: Text(widget.title),
      subtitle: const Text('Pick from camera or gallery'),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () async {
        final action = await showModalBottomSheet<String>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(ctx, 'gallery'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove'),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
              ],
            ),
          ),
        );

        switch (action) {
          case 'camera':
            await _pick(ImageSource.camera);
            break;
          case 'gallery':
            await _pick(ImageSource.gallery);
            break;
          case 'remove':
            setState(() => _file = null);
            widget.onChanged(null);
            break;
          default:
            break;
        }
      },
    );
  }
}
