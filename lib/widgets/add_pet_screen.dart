import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/rtdb_service.dart';
import '../services/permission_service.dart';
// If you already created StorageService earlier for uploads, keep this import;
// otherwise comment it out until you add StorageService.
// import '../services/storage_service.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Mode
  bool _isProduct = false; // false = Pet, true = Product

  // ---- Pet fields ----
  String? name, breed, age, gender, typePet;

  // ---- Product fields ----
  String? pName, pDetail, pDescription;
  int? pPrice;
  int? pOriginalPrice;

  // ---- Picked image (shared) ----
  XFile? _imageFile;
  final _picker = ImagePicker();

  // Common helper
  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Enter $label' : null;

  Future<void> _selectFromGallery() async {
    final ok = await PermissionService.ensurePhotoPermission();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
      return;
    }
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1440,
    );
    if (img != null) {
      setState(() => _imageFile = img);
    }
  }

  // Uncomment if you want camera capture too
  // Future<void> _captureWithCamera() async {
  //   final ok = await PermissionService.ensureCameraPermission();
  //   if (!ok) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Camera permission denied')),
  //     );
  //     return;
  //   }
  //   final img = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 85,
  //     maxWidth: 1440,
  //   );
  //   if (img != null) {
  //     setState(() => _imageFile = img);
  //   }
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill required fields')));
      return;
    }
    _formKey.currentState!.save();

    try {
      if (_isProduct) {
        // -------- Save PRODUCT to RTDB --------
        final id = await RTDBService.addProduct({
          'name': pName,
          'nameLower': (pName ?? '').toLowerCase(),
          'detail': pDetail,
          'description': (pDescription ?? '').trim().isEmpty ? null : pDescription,
          'price': pPrice ?? 0,
          'originalPrice': pOriginalPrice,
          'imgUrl': '', // will update if image chosen
        });

        // If you added StorageService, upload + update imgUrl:
        // if (_imageFile != null) {
        //   final url = await StorageService.uploadProductImage(id, _imageFile!);
        //   await RTDBService.db.child('products/$id').update({'imgUrl': url});
        // }
      } else {
        // -------- Save PET to RTDB --------
        final id = await RTDBService.addPet({
          'name': name,
          'nameLower': (name ?? '').toLowerCase(),
          'typePet': typePet,
          'breed': breed,
          'age': age,
          'gender': gender,
          'price': 0,
          'weight': null,
          'description': null,
          'imgUrl': '', // will update if image chosen
        });

        // If you added StorageService, upload + update imgUrl:
        // if (_imageFile != null) {
        //   final url = await StorageService.uploadPetImage(id, _imageFile!);
        //   await RTDBService.db.child('pets/$id').update({'imgUrl': url});
        // }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _imageFile != null
        ? ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(_imageFile!.path),
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    )
        : const Text('No image selected', style: TextStyle(color: Colors.black54));

    return Scaffold(
      appBar: AppBar(title: Text(_isProduct ? 'Add New Product' : 'Add New Pet')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ------ Toggle: Pet / Product ------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Pet'),
                    selected: !_isProduct,
                    onSelected: (s) => setState(() => _isProduct = false),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Product'),
                    selected: _isProduct,
                    onSelected: (s) => setState(() => _isProduct = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ------ Image pick buttons + preview ------
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(width: 12),
                  // If you want a camera button, uncomment:
                  // OutlinedButton.icon(
                  //   onPressed: _captureWithCamera,
                  //   icon: const Icon(Icons.photo_camera),
                  //   label: const Text('Use Camera'),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              preview,
              const SizedBox(height: 16),

              // ------ PET FORM ------
              if (!_isProduct) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => _required(v, 'name'),
                  onSaved: (v) => name = v?.trim(),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  value: typePet,
                  items: const [
                    DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                    DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                    DropdownMenuItem(value: 'Turtle', child: Text('Turtle')),
                    DropdownMenuItem(value: 'Bird', child: Text('Bird')),
                    DropdownMenuItem(value: 'Rabbit', child: Text('Rabbit')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  validator: (v) => (v == null || v.isEmpty) ? 'Select type' : null,
                  onChanged: (v) => setState(() => typePet = v),
                  onSaved: (v) => typePet = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Breed'),
                  validator: (v) => _required(v, 'breed'),
                  onSaved: (v) => breed = v?.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: (v) => _required(v, 'age'),
                  onSaved: (v) => age = v?.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (v) => _required(v, 'gender'),
                  onSaved: (v) => gender = v?.trim(),
                ),
              ],

              // ------ PRODUCT FORM ------
              if (_isProduct) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => _required(v, 'product name'),
                  onSaved: (v) => pName = v?.trim(),
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Detail (e.g., Food, Bag, Dog)'),
                  validator: (v) => _required(v, 'detail'),
                  onSaved: (v) => pDetail = v?.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter price';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0) return 'Enter a valid price';
                    return null;
                  },
                  onSaved: (v) => pPrice = int.tryParse(v!.trim()),
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Original Price (optional)'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => pOriginalPrice =
                  (v == null || v.trim().isEmpty) ? null : int.tryParse(v.trim()),
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                  onSaved: (v) => pDescription = v?.trim(),
                ),
              ],

              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B8BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_isProduct ? 'Save Product' : 'Save Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
