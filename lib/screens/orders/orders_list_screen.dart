import 'package:flutter/material.dart';

class OrdersListScreen extends StatelessWidget {
  final orders = [
    {
      'id': '#A123',
      'date': '12 Jun 2025',
      'status': 'Delivered',
      'items': 2,
      'total': 139,
    },
    {
      'id': '#A124',
      'date': '10 Jun 2025',
      'status': 'Processing',
      'items': 1,
      'total': 30,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, i) {
          final order = orders[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Icon(Icons.receipt_long, color: Color(0xFF4B8BFF), size: 32),
              title: Text("Order ${order['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${order['date']} • ${order['items']} items\nStatus: ${order['status']}"),
              trailing: Text("\$${order['total']}", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen()));
              },
            ),
          );
        },
      ),
    );
  }
}
