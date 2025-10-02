import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// RTDB instead of Firestore
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:pawpal/screens/auth/login_screen.dart';
import 'package:pawpal/screens/profile/profile_faq_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _blue = Color(0xFF357BFF);

  /// Gradient tuned to header image (soft periwinkle -> very light sky)
  static const _headerGradient = LinearGradient(
    colors: [Color(0xFFA9C3FF), Color(0xFFD3EEFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String _name = 'Amel Jane';
  String? _photoUrl;
  String? _email;
  String? _city;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FirebaseCrashlytics.instance.log('ProfileScreen:initState');
    FirebaseCrashlytics.instance.setCustomKey('route', '/profile');
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? 'signed_out');
      await FirebaseCrashlytics.instance.setCustomKey('userId', uid ?? 'signed_out');

      if (uid != null) {
        final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
        final data = snap.value;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          _name = (map['name'] ?? _name).toString();
          _photoUrl = (map['photoUrl'] as String?)?.trim();
          _email = (map['email'] as String?)?.trim();
          _city = (map['city'] as String?)?.trim();

          // Set individual custom keys (most compatible)
          await FirebaseCrashlytics.instance.setCustomKey('profile_name', _name);
          await FirebaseCrashlytics.instance.setCustomKey('profile_email', _email ?? '');
          await FirebaseCrashlytics.instance.setCustomKey('profile_city', _city ?? '');
          await FirebaseCrashlytics.instance
              .setCustomKey('has_photo', (_photoUrl != null && _photoUrl!.isNotEmpty));
        }
      }
    } catch (e, st) {
      // Keep defaults on failure but log to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileScreen:_loadProfile failed',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    FirebaseCrashlytics.instance.log('ProfileScreen:logout tapped');
    try {
      await FirebaseAuth.instance.signOut();
      FirebaseCrashlytics.instance.log('ProfileScreen:logout success');
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileScreen:logout failed',
      );
    } finally {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    }
  }

  /// Copies this device's FCM token to clipboard and shows a toast.
  Future<void> _copyFcmToken() async {
    FirebaseCrashlytics.instance.log('ProfileScreen:copyFcmToken tapped');
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      if (token == null || token.isEmpty) {
        FirebaseCrashlytics.instance.log('ProfileScreen:FCM token is null/empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FCM token is null. Allow notifications and try again.')),
        );
        return;
      }
      await Clipboard.setData(ClipboardData(text: token));
      // only store a preview, not the full token
      await FirebaseCrashlytics.instance
          .setCustomKey('fcm_token_preview', '${token.substring(0, 8)}...');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM token copied to clipboard')),
      );
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'ProfileScreen:_copyFcmToken failed',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get FCM token: $e')),
      );
    }
  }

  /// ✅ Force a test crash (debug)
  void _forceCrash() {
    FirebaseCrashlytics.instance.log('ProfileScreen:ForceCrash tapped');
    developer.log('ForceCrash tapped -> throwing StateError');
    throw StateError('🔥 Test crash triggered from ProfileScreen (debug button)');
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log('ProfileScreen:build');

    return Scaffold(
      backgroundColor: Colors.white,
      // Build our own header on the gradient (no AppBar background)
      body: Stack(
        children: [
          // 1) Gradient header (bottom)
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: _headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),

          // 2) Content (middle)
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // Blue name card at lower edge of header
              Container(
                margin: const EdgeInsets.only(top: 100, bottom: 22),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? NetworkImage(_photoUrl!)
                            : const AssetImage('assets/user.jpg') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _loading ? '...' : _name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseCrashlytics.instance.log('ProfileScreen:EditProfile tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ).then((_) {
                          FirebaseCrashlytics.instance
                              .log('ProfileScreen:returned from EditProfile -> reload');
                          _loadProfile();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),

              // Tiles — white bg + black border
              _ProfileTile(label: 'About Apps', onTap: () {
                FirebaseCrashlytics.instance.log('ProfileScreen:About tapped');
              }),
              const SizedBox(height: 14),
              _ProfileTile(
                label: 'FAQ',
                onTap: () {
                  FirebaseCrashlytics.instance.log('ProfileScreen:FAQ tapped');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileFaqScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ✅ New tile to copy the device's FCM token
              _ProfileTile(label: 'Copy FCM Token', onTap: _copyFcmToken),

              const SizedBox(height: 14),
              _ProfileTile(label: 'Privacy Policy', onTap: () {
                FirebaseCrashlytics.instance.log('ProfileScreen:PrivacyPolicy tapped');
              }),
              const SizedBox(height: 14),
              _ProfileTile(label: 'Rating Apps', onTap: () {
                FirebaseCrashlytics.instance.log('ProfileScreen:Rating tapped');
              }),
              const SizedBox(height: 14),
              _ProfileTile(label: 'Logout', onTap: _logout),

              const SizedBox(height: 14),
              // ✅ DEBUG-ONLY tile — remove/comment for release if desired
              _ProfileTile(
                label: 'Force Crash (Debug)',
                onTap: _forceCrash,
              ),

              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'Version App 1.0',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ),
            ],
          ),

          // 3) Header with back button (TOP so it captures taps)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          FirebaseCrashlytics.instance.log('ProfileScreen:Back to home');
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home', // your homepage route
                                (route) => false,
                          );
                        },
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16.5,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
