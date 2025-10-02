import 'package:flutter/material.dart';

class ProfileFaqScreen extends StatefulWidget {
  const ProfileFaqScreen({Key? key}) : super(key: key);

  @override
  State<ProfileFaqScreen> createState() => _ProfileFaqScreenState();
}

class _ProfileFaqScreenState extends State<ProfileFaqScreen> {
  final List<Map<String, String>> _qa = const [
    {
      "q": "What is a pet lovers app?",
      "a":
      "Pet lovers application is an application intended for pet lovers. This application has shop, adoption, veterinarian, and treatment features."
    },
    {
      "q": "Can I sell my pet?",
      "a": "Yes, you can sell your pet through the adoption or shop section."
    },
    {
      "q": "How is the adoption process?",
      "a":
      "You can browse adoptable pets, contact the owner, and schedule a meet-up or home visit."
    },
  ];

  late List<bool> _open;

  @override
  void initState() {
    super.initState();
    // first one open like the screenshot
    _open = List<bool>.generate(_qa.length, (i) => i == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Transparent app bar with just a back button (title is in the body)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          const SizedBox(height: 4),
          const Text(
            'FAQ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 18),

          // Cards
          for (int i = 0; i < _qa.length; i++) ...[
            _FaqCard(
              question: _qa[i]["q"]!,
              answer: _qa[i]["a"]!,
              isOpen: _open[i],
              onTap: () => setState(() => _open[i] = !_open[i]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;

  const _FaqCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.isOpen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isOpen ? 0.5 : 0.0, // rotate chevron when open
                    child: const Icon(Icons.expand_more, color: Colors.black87),
                  ),
                ],
              ),
              // Body
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 4, bottom: 2),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
