import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/cart_provider.dart';
import 'package:pawpal/providers/models/cart_item.dart';
import 'package:pawpal/screens/shop/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Items count
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 2, top: 0),
            child: Row(
              children: [
                Text(
                  '${cart.itemCount} ${cart.itemCount == 1 ? "Item" : "Items"}',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: cart.items.isEmpty
                ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
                : ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey[200], thickness: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItem(
                  item: item,
                  onIncrement: () => context.read<CartProvider>().incrementQty(index),
                  onDecrement: () => context.read<CartProvider>().decrementQty(index),
                  onDelete: () => context.read<CartProvider>().removeItemByIndex(index),
                );
              },
            ),
          ),

          // Total bar
          _CartTotalBar(total: cart.subtotal),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItem({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = item.img.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: isNetwork
                ? Image.network(item.img, width: 58, height: 58, fit: BoxFit.cover)
                : Image.asset(item.img, width: 58, height: 58, fit: BoxFit.cover),
          ),
          SizedBox(width: 15),

          // Name, detail, qty
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  SizedBox(height: 2),
                  Text(item.detail, style: TextStyle(fontSize: 13, color: Colors.black54)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _QtyBtn(icon: Icons.add, color: Color(0xFF4B8BFF), onTap: onIncrement),
                      SizedBox(width: 7),
                      Text("${item.qty}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 7),
                      _QtyBtn(icon: Icons.remove, color: Colors.grey[300], iconColor: Colors.grey[700], onTap: onDecrement),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Price and Delete
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prices in one Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (item.originalPrice != null && item.originalPrice! > item.price) ...[
                      Text(
                        '\$${item.originalPrice}',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                    Text(
                      '\$${item.price}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline, color: Colors.red, size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, this.color, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.grey[200],
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5.5),
          child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
        ),
      ),
    );
  }
}

class _CartTotalBar extends StatelessWidget {
  final int total;
  const _CartTotalBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.white,
      ),
      padding: EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sub Total", style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  "\$$total",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B8BFF), fontSize: 21),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutScreen()),
                );
              },
              child: Text('Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4B8BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
