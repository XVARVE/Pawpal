import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              SizedBox(height: 80),
              // Success image
              Image.asset(
                'assets/images/Success.png', // <-- Put your success image here!
                height: 170,
                width: 170,
              ),
              SizedBox(height: 45),
              // Thank you!
              Text(
                "Thank you!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Your purchase was successful",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              // See My Transaction Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () {
                    // Implement navigation to transaction/history page here
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF4B8BFF), width: 1.5),
                    foregroundColor: Color(0xFF4B8BFF),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text("See My Transaction"),
                ),
              ),
              SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}
