import 'package:flutter/material.dart';

class VetAppointmentSuccessScreen extends StatelessWidget {
  const VetAppointmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered text (but not absolute center)
            Align(
              alignment: Alignment(0, -0.1), // slightly lower than center
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Thank you!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Schedule an appointment with a veterinarian\nsuccessfully created.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Button at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 36,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      // You can pop to home or root here
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF4B8BFF),
                      side: BorderSide(color: Color(0xFF4B8BFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text("Back to home"),
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
