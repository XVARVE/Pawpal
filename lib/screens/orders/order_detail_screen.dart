import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final order = {
      'id': '#A123',
      'date': '12 Jun 2025',
      'status': 'Delivered',
      'address': '123 Main Street, California, US',
      'items': [
        {'name': 'Pet Bag', 'qty': 1, 'price': 79},
        {'name': 'Cute Glasses', 'qty': 2, 'price': 30},
      ],
      'total': 139,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Detail", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.receipt_long, color: Color(0xFF4B8BFF), size: 32),
              title: Text("Order ${order['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${order['date']}"),
              trailing: Text(order['status']!, style: TextStyle(color: Color(0xFF4B8BFF))),
            ),
            Divider(height: 28),
            Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.w600)),
            Text(order['address']!, style: TextStyle(color: Colors.black87)),
            Divider(height: 28),
            Text("Items", style: TextStyle(fontWeight: FontWeight.w600)),
            ...List.generate(order['items']!.length, (i) {
              final item = order['items']![i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item['name']),
                trailing: Text("x${item['qty']}   \$${item['price']}"),
              );
            }),
            Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text("\$${order['total']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
