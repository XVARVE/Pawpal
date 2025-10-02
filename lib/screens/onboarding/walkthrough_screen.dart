import 'package:flutter/material.dart';

class WalkthroughScreen extends StatefulWidget {
  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    {
      'image': 'assets/images/Walkthrough1.png',
      'title': 'Find your best pet easily & quickly',
    },
    {
      'image': 'assets/images/Walkthrough2.png',
      'title': 'Adopt, shop, or get treatment for your pet',
    },
    {
      'image': 'assets/images/Walkthrough3.png',
      'title': 'Connect with experienced veterinarians',
    },
  ];

  void _onRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  void _onLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            SizedBox(height: 80),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page['image']!, height: 160),
                      SizedBox(height: 40),
                      Text(
                        page['title']!,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (i) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Color(0xFF4B8BFF) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _onRegister(context),
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,), // White text
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2F80ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),// More round
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () => _onLogin(context),
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold), // White text
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF4B8BFF), width: 2),
                   // Filled outlined button with white text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22), // More round
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
