import 'package:flutter/material.dart';
import 'package:pawpal/screens/adoption/adoption_list.dart';
import 'package:pawpal/screens/adoption/adoption_schedule_screen.dart';

class AdoptionDetailScreen extends StatefulWidget {
  final List<String> images;        // can be http(s) urls, asset paths, or empty
  final String name, breed, age, gender, weight, desc;
  final int price;                  // kept for layout (not used for cart)

  const AdoptionDetailScreen({
    Key? key,
    required this.images,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.desc,
    this.price = 15,
  }) : super(key: key);

  @override
  State<AdoptionDetailScreen> createState() => _AdoptionDetailScreenState();
}

class _AdoptionDetailScreenState extends State<AdoptionDetailScreen> {
  int _currentImg = 0;

  @override
  Widget build(BuildContext context) {
    // ensure there is at least one slot to render (placeholder if empty)
    final imgs = (widget.images.isNotEmpty) ? widget.images : [''];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Adopt Pet",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(Icons.favorite_border, color: Colors.black54),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image carousel (network/asset/placeholder support)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 8, right: 8),
            child: SizedBox(
              width: double.infinity,
              height: 400,
              child: PageView.builder(
                itemCount: imgs.length,
                controller: PageController(viewportFraction: 0.92, initialPage: _currentImg),
                onPageChanged: (idx) => setState(() => _currentImg = idx),
                itemBuilder: (context, idx) {
                  final src = imgs[idx];
                  final isNet = src.startsWith('http');
                  final hasImg = src.isNotEmpty;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: hasImg
                          ? (isNet
                          ? Image.network(src, fit: BoxFit.cover, width: double.infinity, height: 220)
                          : Image.asset(src, fit: BoxFit.cover, width: double.infinity, height: 220))
                          : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(Icons.pets, size: 48, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Scrollable pet details
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              children: [
                // Name + Price row (price kept for layout parity)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          SizedBox(height: 2),
                          Text(widget.breed, style: TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Text(
                      "\$${widget.price}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Age/Sex/Weight
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      _DetailInfo(label: "Age", value: widget.age),
                      _DetailInfo(label: "Sex", value: widget.gender),
                      _DetailInfo(label: "Weight", value: (widget.weight.isNotEmpty) ? widget.weight : '3 Kg'),
                    ],
                  ),
                ),
                SizedBox(height: 18),

                Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  widget.desc.isNotEmpty ? widget.desc : 'No description provided.',
                  style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.45),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),

          // Sticky bottom bar for buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Optional: navigate to chat like your shop pet detail
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatSellerScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4B8BFF)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Color(0xFF4B8BFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    child: Text("Chat Seller"),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Keep same navigation, pass the first valid image (network/asset/placeholder-safe)
                      final chosenImg = imgs.firstWhere(
                            (s) => s.isNotEmpty,
                        orElse: () => '',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdoptionScheduleScreen(
                            petImg: chosenImg,
                            petName: widget.name,
                            petBreed: widget.breed,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B8BFF),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      elevation: 0,
                    ),
                    child: Text("Continue", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final String label;
  final String value;
  const _DetailInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.black54, fontSize: 14)),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
