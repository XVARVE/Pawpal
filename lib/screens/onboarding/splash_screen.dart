import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4B8BFF),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/Logo.png', height: 120),
                SizedBox(height: 30),
                Text(
                  'Be happy and Enjoy with pet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/walkthrough');
              },
              child: Icon(Icons.arrow_forward, color: Color(0xFF4B8BFF)),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }
}
