import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim().toLowerCase();
    if (value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Please enter a valid email address';
    return null;
  }

  String? _passValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Ensures a profile exists in RTDB at `/users/{uid}`.
  /// If missing, it creates a minimal profile that matches your RTDB rules.
  Future<void> _ensureRtdbProfile(User user) async {
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snap = await ref.get();
    if (!snap.exists) {
      final email = (user.email ?? _emailCtrl.text.trim()).toLowerCase();
      final rawName = (user.displayName ?? '').trim();
      final fallbackName = email.isNotEmpty ? email.split('@').first : '';
      final name = rawName.isEmpty ? fallbackName : rawName;

      await ref.set({
        'name': name,
        'nameLower': name.toLowerCase(),
        'email': email,
        'emailLower': email,
        'phone': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'city': '',
        'address': '',
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await _ensureRtdbProfile(cred.user!);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed. Please try again.';
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found for this email. Please register first.';
          break;
        case 'wrong-password':
          msg = 'Incorrect password. Try again or use "Forgot Password".';
          break;
        case 'invalid-credential':
          msg = 'Invalid credentials. Please check your email and password.';
          break;
        case 'invalid-email':
          msg = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          msg = 'This account has been disabled.';
          break;
        default:
          msg = e.message ?? msg;
      }
      _toast(msg);
    } catch (e) {
      _toast('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------- Google Sign-In ----------
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
        if (googleUser == null) {
          // User cancelled picker; just exit gracefully
          return;
        }
        final googleAuth = await googleUser.authentication;
        final oauthCred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await FirebaseAuth.instance.signInWithCredential(oauthCred);
      }

      await _ensureRtdbProfile(cred.user!);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Google sign-in failed.');
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------- Facebook Sign-In ----------
  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;

      if (kIsWeb) {
        final provider = FacebookAuthProvider();
        provider.addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
        );

        if (result.status == LoginStatus.success) {
          final at = result.accessToken; // AccessToken?
          if (at == null) {
            throw Exception('Facebook access token is null');
          }
          // Use tokenString for your plugin version
          final oauthCred = FacebookAuthProvider.credential(at.tokenString);
          cred = await FirebaseAuth.instance.signInWithCredential(oauthCred);
        } else if (result.status == LoginStatus.cancelled) {
          _toast('Facebook sign-in cancelled.');
          return;
        } else {
          throw PlatformException(
            code: 'facebook-login-failed',
            message: result.message ?? 'Facebook login failed',
          );
        }
      }

      await _ensureRtdbProfile(cred.user!);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Facebook sign-in failed.');
    } catch (e) {
      _toast('Facebook sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 36),

              // Email Field
              const Text('Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Input your email',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Password Field
              const Text('Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                validator: _passValidator,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Input your password',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3887F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Login',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),

              const SizedBox(height: 60),

              // OR divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR login with', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 60),

              // Social buttons (now functional)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey, width: 1.2),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: Image.asset('assets/images/Google.png', width: 20, height: 20),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Google',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide.none),
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey, width: 1.2),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _signInWithFacebook,
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 26),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Facebook',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide.none),
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
