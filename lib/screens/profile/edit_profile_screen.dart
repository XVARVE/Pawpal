import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController(text: 'Amel');
  final _email = TextEditingController(text: 'Amelcamel@gmail.com');
  final _phone = TextEditingController(text: '0899-000-0000');
  final _address = TextEditingController(text: 'California, US');

  String? _photoUrl; // optional, for later
  bool _loading = true;
  bool _saving = false;

  InputDecoration _pillDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(32)),
      borderSide: BorderSide(color: Color(0xFF4B8BFF), width: 1.6),
    ),
  );

  InputDecoration _boxDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFF4B8BFF), width: 1.6),
    ),
  );

  @override
  void initState() {
    super.initState();
    FirebaseCrashlytics.instance.log('EditProfileScreen:initState');
    FirebaseCrashlytics.instance.setCustomKey('route', '/profile/edit');
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? 'signed_out');
      await FirebaseCrashlytics.instance.setCustomKey('userId', uid ?? 'signed_out');

      if (uid != null) {
        final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
        final data = snap.value;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          _name.text = (map['name'] ?? _name.text).toString();
          _email.text = (map['email'] ?? _email.text).toString();
          _phone.text = (map['phone'] ?? _phone.text).toString();
          _address.text = (map['address'] ?? _address.text).toString();
          _photoUrl = (map['photoUrl'] as String?)?.trim();

          // Individual keys for compatibility
          await FirebaseCrashlytics.instance.setCustomKey('edit_name_len', _name.text.length);
          await FirebaseCrashlytics.instance.setCustomKey('edit_email_len', _email.text.length);
          await FirebaseCrashlytics.instance
              .setCustomKey('edit_has_photo', _photoUrl != null && _photoUrl!.isNotEmpty);
        }
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'EditProfileScreen:_loadUser failed',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    FirebaseCrashlytics.instance.log('EditProfileScreen:save tapped');

    try {
      final ref = FirebaseDatabase.instance.ref('users/$uid');
      final name = _name.text.trim();
      final email = _email.text.trim();

      // Annotate values we’re about to write
      await FirebaseCrashlytics.instance.setCustomKey('save_name_len', name.length);
      await FirebaseCrashlytics.instance.setCustomKey('save_email_len', email.length);
      await FirebaseCrashlytics.instance
          .setCustomKey('save_phone_len', _phone.text.trim().length);
      await FirebaseCrashlytics.instance
          .setCustomKey('save_has_address', _address.text.trim().isNotEmpty);

      await ref.update({
        'name': name,
        'nameLower': name.toLowerCase(),
        'email': email,
        'emailLower': email.toLowerCase(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'photoUrl': _photoUrl ?? '',
        'updatedAt': ServerValue.timestamp,
      });

      FirebaseCrashlytics.instance.log('EditProfileScreen:save success');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'EditProfileScreen:save failed',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log('EditProfileScreen:build');

    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Curved gradient header (exact look) ----
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(w, 140),
                  bottomRight: Radius.elliptical(w, 140),
                ),
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9CCBFF), Color(0xFFBFD9FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // top row: back + centered title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () {
                                  FirebaseCrashlytics.instance.log('EditProfileScreen:back');
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // avatar with white ring (prefers network if set)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                              ? NetworkImage(_photoUrl!)
                              : const AssetImage('assets/user.jpg') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Form content ----
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Name'),
                    const SizedBox(height: 8),
                    TextField(controller: _name, decoration: _pillDecoration('Amel')),

                    const SizedBox(height: 22),
                    const _Label('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _pillDecoration('amel@email.com'),
                    ),

                    const SizedBox(height: 22),
                    const _Label('Phone'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _pillDecoration('08xx-xxxx-xxxx'),
                    ),

                    const SizedBox(height: 22),
                    const _Label('Address'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _address,
                      maxLines: 4,
                      decoration: _boxDecoration('Your address'),
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B8BFF),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );
}
