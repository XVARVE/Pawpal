import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topics = [
      'How to adopt a pet?',
      'How to buy pet products?',
      'How to chat with sellers?',
      'Payment & refunds',
      'Delivery information',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Center", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: topics.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, i) {
          return ListTile(
            leading: Icon(Icons.help_outline, color: Color(0xFF4B8BFF)),
            title: Text(topics[i]),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Could navigate to a detailed FAQ screen
            },
          );
        },
      ),
    );
  }
}
