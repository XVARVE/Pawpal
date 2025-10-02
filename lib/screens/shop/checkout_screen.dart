import 'package:flutter/material.dart';
import 'package:pawpal/screens/shop/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/cart_provider.dart';
import 'package:pawpal/providers/models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isShip = true;
  String _paymentMethod = "Paypal";

  void _showPaymentSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: false,
      builder: (context) {
        return _PaymentSheet(
          selected: _paymentMethod,
          onSelected: (method) {
            Navigator.pop(context, method);
          },
        );
      },
    );

    if (result != null) {
      setState(() => _paymentMethod = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>(); // <-- dynamic cart

    return Scaffold(
      backgroundColor: Colors.white, // FULL WHITE BACKGROUND
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Delivery Type'),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _TypeBtn(
                            text: "Pick up",
                            selected: !isShip,
                            onTap: () => setState(() => isShip = false),
                          ),
                          SizedBox(width: 15),
                          _TypeBtn(
                            text: "Ship",
                            selected: isShip,
                            onTap: () => setState(() => isShip = true),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery To',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "California, US 2000\n+9905-1950",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Edit Address",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 0, thickness: 1.1),
                section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Contact Info'),
                      SizedBox(height: 9),
                      Text(
                        "Jenny Fisher",
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 1),
                      Text("+9905-1950", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                Divider(height: 0, thickness: 1.1),
                section(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Payment Method'),
                      SizedBox(height: 7),
                      GestureDetector(
                        onTap: _showPaymentSheet,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_paymentMethod,
                                  style: TextStyle(fontSize: 16)),
                              Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 0, thickness: 1.1),

                // ---- Your Items (DYNAMIC) ----
                section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Your Items'),
                      SizedBox(height: 13),
                      if (cart.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No items in cart',
                            style: TextStyle(
                                fontSize: 15, color: Colors.black54),
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (final item in cart.items) ...[
                              _CheckoutLine(item: item),
                              SizedBox(height: 10),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),

                Divider(height: 0, thickness: 1.1),

                // ---- Promo Code (unchanged) ----
                section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Promo Code'),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Enter promo code",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                  BorderSide(color: Color(0xFF4B8BFF)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4B8BFF),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                            child: Text(
                              'Check',
                              style:
                              TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                Divider(height: 0, thickness: 1.1),

                // ---- Order Summary (DYNAMIC subtotal) ----
                section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Order Summary'),
                      SizedBox(height: 11),
                      summaryRow("Sub Total", "\$${cart.subtotal}"),
                      summaryRow("Delivery Fee", "Free",
                          valueColor: Colors.green),
                      summaryRow("Tax", "\$0"),
                    ],
                  ),
                ),
                SizedBox(height: 35),
              ],
            ),
          ),

          // ---- Bottom checkout bar (DYNAMIC total) ----
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sub Total", style: TextStyle(fontSize: 15)),
                        Text(
                          "\$${cart.subtotal}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: Color(0xFF357BFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: cart.items.isEmpty
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF357BFF),
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                        // Disable style if no items
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.white,
                      ),
                      child: Text('Checkout',
                          style: TextStyle(fontSize: 19, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---- Helper widgets ----
  Widget section({required Widget child, Color? color}) => Container(
    width: double.infinity,
    color: Colors.white, // Always white background
    padding: EdgeInsets.fromLTRB(18, 17, 18, 17),
    child: child,
  );

  Widget summaryRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16)),
            Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
          ],
        ),
      );

  Widget sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 19,
      letterSpacing: 0.1,
    ),
  );
}

class _TypeBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TypeBtn(
      {required this.text, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11, horizontal: 26),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF357BFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
              color: selected ? Color(0xFF357BFF) : Colors.grey, width: 1.6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet for Payment Selection
class _PaymentSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  _PaymentSheet({required this.selected, required this.onSelected});

  final _options = [
    "Cash On Delivery",
    "Paypal",
    "G-Pay",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 5,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Select Payment",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 18),
          ..._options.map((o) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(o,
                style: TextStyle(
                    fontWeight:
                    o == selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 17,
                    color: Colors.black)),
            trailing: Radio<String>(
              value: o,
              groupValue: selected,
              onChanged: (_) => onSelected(o),
              activeColor: Color(0xFF357BFF),
            ),
            onTap: () => onSelected(o),
          )),
        ],
      ),
    );
  }
}

/// A single line for an item in the checkout "Your Items" section.
/// (Keeps your existing visual style.)
class _CheckoutLine extends StatelessWidget {
  final CartItem item;
  const _CheckoutLine({required this.item});

  @override
  Widget build(BuildContext context) {
    final isNetwork = item.img.startsWith('http');

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: isNetwork
              ? Image.network(item.img, width: 48, height: 48, fit: BoxFit.cover)
              : Image.asset(item.img, width: 48, height: 48, fit: BoxFit.cover),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              SizedBox(height: 1),
              Text(item.detail,
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Text('\$${item.price}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ],
    );
  }
}
