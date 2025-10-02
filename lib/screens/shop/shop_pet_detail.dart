import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawpal/providers/cart_provider.dart';
import 'package:pawpal/providers/models/cart_item.dart';
import 'package:pawpal/screens/shop/chat_seller.dart';
import 'package:provider/provider.dart';

class ShopPetDetailScreen extends StatefulWidget {
  final String img;
  final String name;
  final String age;
  final String gender;
  final int price;

  // Optional extras to fill existing fields in the UI
  final String? breed;        // subtitle
  final String? weight;       // weight column ("3 Kg" fallback)
  final String? description;  // description text

  // If provided, we’ll fetch fresh data and override the above fields.
  final String? petId;

  const ShopPetDetailScreen({
    Key? key,
    required this.img,
    required this.name,
    required this.age,
    required this.gender,
    required this.price,
    this.breed,
    this.weight,
    this.description,
    this.petId,
  }) : super(key: key);

  @override
  State<ShopPetDetailScreen> createState() => _ShopPetDetailScreenState();
}

class _ShopPetDetailScreenState extends State<ShopPetDetailScreen> {
  bool isFavorite = false;
  final List<String> petImages = [];
  int _selectedImgIndex = 0;

  // Local copies so we can override with Firestore values if petId is given
  late String _img;
  late String _name;
  late String _age;
  late String _gender;
  late int _price;
  String? _breed;
  String? _weight;
  String? _description;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Seed from constructor
    _img = widget.img;
    _name = widget.name;
    _age = widget.age;
    _gender = widget.gender;
    _price = widget.price;
    _breed = widget.breed;
    _weight = widget.weight;
    _description = widget.description;

    petImages.add(_img);

    // If a Firestore id is provided, fetch latest values (no layout change)
    if (widget.petId != null && widget.petId!.isNotEmpty) {
      _fetchPet(widget.petId!);
    }
  }

  Future<void> _fetchPet(String id) async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance.collection('pets').doc(id).get();
      if (snap.exists) {
        final data = snap.data()!;
        // Normalize price (could be int/double/string)
        final dynamic rawPrice = data['price'];
        int normPrice = 0;
        if (rawPrice is int) {
          normPrice = rawPrice;
        } else if (rawPrice is double) {
          normPrice = rawPrice.round();
        } else if (rawPrice is String) {
          normPrice = int.tryParse(rawPrice) ?? 0;
        }

        final newImg = (data['imgUrl'] ?? '') as String;
        _img = newImg.isNotEmpty ? newImg : _img; // keep old if empty
        _name = (data['name'] ?? _name) as String;
        _age = (data['age'] ?? _age) as String;
        _gender = (data['gender'] ?? _gender) as String;
        _price = normPrice;
        _breed = (data['breed'] ?? _breed) as String?;
        _weight = (data['weight'] ?? _weight) as String?;
        _description = (data['description'] ?? _description) as String?;

        // Refresh images list if the URL changed
        petImages
          ..clear()
          ..add(_img);

        if (mounted) setState(() {});
      }
    } catch (e) {
      // Optionally show a snackbar
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Pet',
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section (same layout)
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
                    child: _loading && petImages.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : PageView.builder(
                      itemCount: petImages.isNotEmpty ? petImages.length : 1,
                      controller: PageController(viewportFraction: 1, initialPage: _selectedImgIndex),
                      onPageChanged: (i) => setState(() => _selectedImgIndex = i),
                      itemBuilder: (context, i) {
                        final src = petImages.isNotEmpty ? petImages[i] : _img;
                        final net = src.startsWith('http');
                        if (src.isEmpty) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Icon(Icons.pets, size: 48, color: Colors.grey),
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

            // Name + Price Row (same)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        _breed?.isNotEmpty == true ? _breed! : "—",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$$_price",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Info row (Age, Sex, Weight) — weight dynamic
            Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailColumn("Age", _age),
                  _DetailColumn("Sex", _gender),
                  _DetailColumn("Weight", (_weight?.trim().isNotEmpty == true) ? _weight! : "3 Kg"),
                ],
              ),
            ),
            SizedBox(height: 18),

            // Description (filled if provided)
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            _loading
                ? Text("Loading...", style: TextStyle(fontSize: 15, color: Colors.black54))
                : Text(
              (_description?.trim().isNotEmpty == true) ? _description! : "No description provided.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),

            Spacer(),

            // Buttons (unchanged visually)
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
                      // Pets cannot be added to cart; guide user to contact the seller
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Pets can’t be added to cart. Please contact the seller.")),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatSellerScreen()),
                      );
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

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;
  const _DetailColumn(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.black54, fontSize: 14)),
          SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
