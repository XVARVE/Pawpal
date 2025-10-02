import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawpal/screens/shop/chat_seller.dart';

// NEW: add these for cart support
import 'package:provider/provider.dart';
import 'package:pawpal/providers/cart_provider.dart';
import 'package:pawpal/providers/models/cart_item.dart';

class ShopProductDetailScreen extends StatefulWidget {
  final String img;
  final String name;
  final String detail;
  final int price;
  final int? originalPrice;

  // dynamic description to replace hardcoded text (optional)
  final String? description;

  // if provided, we’ll fetch the latest fields from Firestore
  final String? productId;

  const ShopProductDetailScreen({
    Key? key,
    required this.img,
    required this.name,
    required this.detail,
    required this.price,
    this.originalPrice,
    this.description,
    this.productId,
  }) : super(key: key);

  @override
  State<ShopProductDetailScreen> createState() => _ShopProductDetailScreenState();
}

class _ShopProductDetailScreenState extends State<ShopProductDetailScreen> {
  bool isFavorite = false;
  final List<String> productImages = [];
  int _selectedImgIndex = 0;

  // Local copies so we can override with Firestore values if productId is given
  late String _img;
  late String _name;
  late String _detail;
  late int _price;
  int? _originalPrice;
  String? _description;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // seed from incoming props
    _img = widget.img;
    _name = widget.name;
    _detail = widget.detail;
    _price = widget.price;
    _originalPrice = widget.originalPrice;
    _description = widget.description;

    productImages.add(_img);

    if (widget.productId != null && widget.productId!.isNotEmpty) {
      _fetchProduct(widget.productId!);
    }
  }

  Future<void> _fetchProduct(String id) async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (snap.exists) {
        final data = snap.data()!;

        int _norm(dynamic v) {
          if (v is int) return v;
          if (v is double) return v.round();
          if (v is String) return int.tryParse(v) ?? 0;
          return 0;
        }

        final newImg = (data['imgUrl'] ?? '') as String;
        _img = newImg.isNotEmpty ? newImg : _img;

        _name = (data['name'] ?? _name) as String;
        _detail = (data['detail'] ?? _detail) as String;
        _price = _norm(data['price']);
        _originalPrice = data['originalPrice'] == null ? null : _norm(data['originalPrice']);
        _description = (data['description'] ?? _description) as String?;

        productImages
          ..clear()
          ..add(_img);

        if (mounted) setState(() {});
      }
    } catch (_) {
      // optional: show a snackbar
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = _img.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white, // Full white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // smoother back
        ),
        title: Center(
          child: Text(
            'Product',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.2,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () => setState(() => isFavorite = !isFavorite),
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel (layout unchanged, supports network)
            SizedBox(
              height: 250,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _loading && productImages.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : PageView.builder(
                      itemCount: productImages.isNotEmpty ? productImages.length : 1,
                      controller: PageController(viewportFraction: 1, initialPage: _selectedImgIndex),
                      onPageChanged: (i) => setState(() => _selectedImgIndex = i),
                      itemBuilder: (context, i) {
                        final src = productImages.isNotEmpty ? productImages[i] : _img;
                        final net = src.startsWith('http');
                        if (src.isEmpty) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Icon(Icons.shopping_bag, size: 48, color: Colors.grey),
                          );
                        }
                        return net
                            ? Image.network(src, fit: BoxFit.cover, width: double.infinity, height: 250)
                            : Image.asset(src, fit: BoxFit.cover, width: double.infinity, height: 250);
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Name + Price Row (unchanged visually)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _detail,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$$_price",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    if (_originalPrice != null && _originalPrice! > _price)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          "\$$_originalPrice",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Spacer for future info row (layout preserved)
            SizedBox(height: 18),

            // Description section (now dynamic, fallback to a short message)
            Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 6),
            _loading
                ? Text("Loading...", style: TextStyle(fontSize: 15, color: Colors.black54))
                : Text(
              (_description?.trim().isNotEmpty == true)
                  ? _description!
                  : "No description provided.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),

            Spacer(),

            // Shop Info Card (unchanged)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              margin: EdgeInsets.only(bottom: 6, top: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Shop Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF9237CD), // Dark purple border
                        width: 3,
                      ),
                      color: Color(0xFFF475FF), // Light purple fill
                    ),
                    child: Center(
                      child: Image.asset('assets/images/PetShop.png', width: 20, height: 20),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Shop Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pet Shop 24", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 1),
                        Text(
                          "6391 Elgin St. Celina, Delaware 10299",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 21),
                      SizedBox(width: 2),
                      Text(
                        "4.8",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),

            // Buttons at the bottom (layout unchanged)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatSellerScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4B8BFF)),
                      foregroundColor: Color(0xFF4B8BFF),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text('Chat Seller'),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Optional sanity check: block if price invalid (shouldn't happen)
                      if (_price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('This product cannot be added right now.')),
                        );
                        return;
                      }

                      // Add only PRODUCTS to cart
                      context.read<CartProvider>().addItem(
                        CartItem(
                          id: widget.productId,   // Firestore product doc id (optional)
                          img: _img,
                          name: _name,
                          detail: _detail,
                          price: _price,
                          originalPrice: _originalPrice,
                          qty: 1,
                        ),
                      );

                      // Optional tiny UX: confirm add
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to cart')),
                      );

                      Navigator.pushNamed(context, '/cart');
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B8BFF),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: Text('Continue', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
