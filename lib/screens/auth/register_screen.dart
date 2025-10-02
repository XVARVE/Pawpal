import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter email';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _requiredValidator(String? v, String field) {
    if (v == null || v.trim().isEmpty) return 'Enter $field';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Min 6 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _pass.text) return 'Passwords do not match';
    return null;
  }

  /// Create minimal profile in RTDB if missing.
  Future<void> _ensureRtdbProfile(User user) async {
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snap = await ref.get();
    if (!snap.exists) {
      final email = (user.email ?? '').toLowerCase();
      final rawName = (user.displayName ?? '').trim();
      final fallbackName = email.isNotEmpty ? email.split('@').first : '';
      final name = rawName.isEmpty ? (_name.text.trim().isNotEmpty ? _name.text.trim() : fallbackName) : rawName;

      await ref.set({
        'name': name,
        'nameLower': name.toLowerCase(),
        'email': email,
        'emailLower': email,
        'phone': user.phoneNumber ?? _phone.text.trim(),
        'photoUrl': user.photoURL ?? '',
        'city': '',
        'address': '',
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _email.text.trim();
      final password = _pass.text.trim();

      // 1) Prevent duplicate email across providers
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        if (methods.contains('password')) {
          _toast('This email is already registered. Please log in instead.');
        } else {
          _toast('This email is already registered with: ${methods.join(', ')}. Use that method to sign in.');
        }
        return;
      }

      // 2) Create account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3) Optional: set displayName
      final name = _name.text.trim();
      if (name.isNotEmpty) {
        await cred.user!.updateDisplayName(name);
      }

      // 4) Save profile in RTDB
      final db = FirebaseDatabase.instance.ref();
      await db.child('users/${cred.user!.uid}').set({
        'name': name,
        'nameLower': name.toLowerCase(),
        'email': email,
        'emailLower': email.toLowerCase(),
        'phone': _phone.text.trim(),
        'address': '',
        'city': '',
        'photoUrl': '',
        'createdAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already in use. Try logging in.';
      } else if (e.code == 'invalid-email') {
        msg = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak (min 6 characters).';
      } else if (e.code == 'operation-not-allowed') {
        msg = 'Email/Password sign-in is disabled for this project.';
      }
      _toast(msg);
    } catch (e) {
      _toast('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- Google OAuth "register" (actually sign-in + ensure profile) ----
  Future<void> _registerWithGoogle() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
        if (googleUser == null) return; // user cancelled
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
      if (e.code == 'account-exists-with-different-credential') {
        _toast('This email exists with another sign-in method. Use that method, then link Google.');
      } else {
        _toast(e.message ?? 'Google sign-in failed.');
      }
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- Facebook OAuth "register" ----
  Future<void> _registerWithFacebook() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;
      if (kIsWeb) {
        final provider = FacebookAuthProvider()..addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
        );

        if (result.status == LoginStatus.success) {
          final at = result.accessToken;
          if (at == null) throw Exception('Facebook access token is null');
          // Your plugin version exposes tokenString
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
      if (e.code == 'account-exists-with-different-credential') {
        _toast('This email exists with another sign-in method. Use that method, then link Facebook.');
      } else {
        _toast(e.message ?? 'Facebook sign-in failed.');
      }
    } catch (e) {
      _toast('Facebook sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- UI helpers ----
  Widget _label(String t) => Text(
    t,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const Text('Register', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _label('Name'),
              TextFormField(
                controller: _name,
                validator: (v) => _requiredValidator(v, 'name'),
                decoration: _decoration('Input your name'),
              ),
              const SizedBox(height: 24),

              _label('Phone'),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: _decoration('Input your phone'),
              ),
              const SizedBox(height: 24),

              _label('Email'),
              TextFormField(
                controller: _email,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Input your email'),
              ),
              const SizedBox(height: 24),

              _label('Password'),
              TextFormField(
                controller: _pass,
                validator: _passwordValidator,
                obscureText: _obscurePassword,
                decoration: _decoration('Input your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Confirm Password'),
              TextFormField(
                controller: _confirmPass,
                validator: _confirmValidator,
                obscureText: _obscureConfirm,
                decoration: _decoration('Re-enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Already have account? Login
              TextButton(
                onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              // Social section
              const SizedBox(height: 40),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR register with', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons styled to match your app
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey, width: 1.2),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _registerWithGoogle,
                      icon: Image.asset('assets/images/Google.png', width: 20, height: 20),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Google',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide.none,
                        ),
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
                      onPressed: _loading ? null : _registerWithFacebook,
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 26),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Facebook',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide.none,
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
