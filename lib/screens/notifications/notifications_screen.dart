import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final notifications = [
    {'title': 'Order Delivered', 'subtitle': 'Your order #A123 has been delivered.', 'time': '10 min ago'},
    {'title': 'New Pet Available', 'subtitle': 'A new puppy is available for adoption!', 'time': '1 hour ago'},
    {'title': 'Promo Alert', 'subtitle': 'Get 20% off on pet products.', 'time': 'Today'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, i) {
          final note = notifications[i];
          return ListTile(
            leading: Icon(Icons.notifications, color: Color(0xFF4B8BFF)),
            title: Text(note['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(note['subtitle']!),
            trailing: Text(note['time']!, style: TextStyle(color: Colors.black54, fontSize: 12)),
          );
        },
      ),
    );
  }
}
