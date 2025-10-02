import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String value) {
    if (value.length == 1 && i < 3) {
      _nodes[i + 1].requestFocus();
    }
    if (value.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  void _onRegisterPressed() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == 4) {
      // Add verification logic here if needed
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter 4-digit code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Confirm Your Number',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We have sent a 4-digit code to +628190124578',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 42), // More space above PIN Input
            // PIN Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    onChanged: (v) => _onChanged(i, v),
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.black26),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.black26),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Color(0xFF3887F6)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 40), // More space below PIN Input
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onRegisterPressed,
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3887F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: RichText(
              text: TextSpan(
                text: "Didn't receive the code? ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        // Add resend logic here
                      },
                      child: Text(
                        "Resend",
                        style: TextStyle(
                          color: Color(0xFF3887F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


          ],
        ),
      ),
    );
  }
}
