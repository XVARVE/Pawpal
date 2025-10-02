import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper around Firebase Storage.
/// Uploads the given image and returns the *download URL*.
class StorageService {
  StorageService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image for a Pet at: uploads/pets/{petId}.{ext}
  static Future<String> uploadPetImage(String petId, XFile file) async {
    final ext = _detectExt(file);
    final ref = _storage.ref('uploads/pets/$petId.$ext');
    return _putAndGetUrl(ref, file, contentType: _contentTypeForExt(ext));
  }

  /// Upload an image for a Product at: uploads/products/{productId}.{ext}
  static Future<String> uploadProductImage(String productId, XFile file) async {
    final ext = _detectExt(file);
    final ref = _storage.ref('uploads/products/$productId.$ext');
    return _putAndGetUrl(ref, file, contentType: _contentTypeForExt(ext));
  }

  /// Generic helper to upload bytes and return the download URL.
  static Future<String> _putAndGetUrl(
      Reference ref,
      XFile file, {
        String? contentType,
      }) async {
    // Prefer bytes (works across platforms)
    final Uint8List data = await file.readAsBytes();
    final meta = SettableMetadata(contentType: contentType ?? 'image/jpeg');

    final task = await ref.putData(data, meta);
    // (Optional) you could inspect task.state/progress here.
    final url = await task.ref.getDownloadURL();
    return url;
  }

  /// Try to detect the file extension from the XFile path; default to jpg
  static String _detectExt(XFile file) {
    final path = file.path;
    final idx = path.lastIndexOf('.');
    if (idx == -1 || idx == path.length - 1) return 'jpg';
    final ext = path.substring(idx + 1).toLowerCase();
    // whitelist a few common image extensions; default to jpg otherwise
    const ok = {'jpg', 'jpeg', 'png', 'webp', 'heic'};
    return ok.contains(ext) ? ext : 'jpg';
  }

  static String _contentTypeForExt(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
