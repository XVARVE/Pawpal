import 'package:flutter/material.dart';
// RTDB instead of Firestore
import 'package:firebase_database/firebase_database.dart';

import 'package:pawpal/providers/favourite_provider.dart';
import 'package:pawpal/screens/shop/shop_product_detail.dart';
import 'package:pawpal/widgets/shop_search_screen.dart';
import 'package:provider/provider.dart';

class ShopProductScreen extends StatefulWidget {
  const ShopProductScreen({Key? key}) : super(key: key);

  @override
  State<ShopProductScreen> createState() => _ShopProductScreenState();
}

class _ShopProductScreenState extends State<ShopProductScreen> {
  String? _searchQuery;

  /// Category filter (“All”, “Glasses”, “Bag”, “Food”, “Vitamin”)
  String _selectedCategory = 'All';

  /// Build RTDB query:
  /// - If searching: orderByChild('nameLower') + startAt/endAt (prefix)
  /// - Else if category != All: orderByChild('detail').equalTo(category)
  /// - Else: orderByChild('createdAt') (sort desc locally)
  Query _buildQuery() {
    final ref = FirebaseDatabase.instance.ref('products');

    if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
      final s = _searchQuery!.trim().toLowerCase();
      return ref.orderByChild('nameLower').startAt(s).endAt('$s\uf8ff');
    }

    if (_selectedCategory != 'All') {
      return ref.orderByChild('detail').equalTo(_selectedCategory);
    }

    return ref.orderByChild('createdAt');
  }

  void _applyCategory(String cat) {
    if (_selectedCategory == cat) return;
    setState(() {
      _selectedCategory = cat;
      // Optional: clear search so the category filter is immediately reflected
      // Comment out next line if you want search + category to co-exist (RTDB can't combine them anyway).
      _searchQuery = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- SEARCH BAR AS ICON (same layout) ---
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShopSearchScreen(onQuerySelected: (query) {}),
                        ),
                      );
                      if (result is String && result.trim().isNotEmpty) {
                        setState(() => _searchQuery = result.trim());
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 10),
                          Text(
                            _searchQuery ?? 'Food for rabbit',
                            style: TextStyle(
                              color: _searchQuery == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_searchQuery != null && _searchQuery!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _searchQuery = null),
                  )
              ],
            ),
            const SizedBox(height: 18),

            // Categories row (now interactive)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    'All',
                    selected: _selectedCategory == 'All',
                    onTap: () => _applyCategory('All'),
                  ),
                  _CategoryChip(
                    'Glasses',
                    selected: _selectedCategory == 'Glasses',
                    onTap: () => _applyCategory('Glasses'),
                  ),
                  _CategoryChip(
                    'Bag',
                    selected: _selectedCategory == 'Bag',
                    onTap: () => _applyCategory('Bag'),
                  ),
                  _CategoryChip(
                    'Food',
                    selected: _selectedCategory == 'Food',
                    onTap: () => _applyCategory('Food'),
                  ),
                  _CategoryChip(
                    'Vitamin',
                    selected: _selectedCategory == 'Vitamin',
                    onTap: () => _applyCategory('Vitamin'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product Grid driven by RTDB
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _buildQuery().onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final raw = snapshot.data?.snapshot.value;
                  if (raw == null) {
                    return const Center(child: Text('No products found'));
                  }

                  // RTDB shape: { "-Nab123": { name:.., ... }, ... }
                  final List<Map<String, dynamic>> products = [];
                  if (raw is Map) {
                    raw.forEach((key, value) {
                      if (value is Map) {
                        final m = Map<String, dynamic>.from(value as Map);
                        m['id'] = key;
                        products.add(m);
                      }
                    });
                  } else if (raw is List) {
                    // In case the node is a list (rare with push keys, but safe-guard)
                    for (var i = 0; i < raw.length; i++) {
                      final value = raw[i];
                      if (value is Map) {
                        final m = Map<String, dynamic>.from(value);
                        m['id'] = '$i';
                        products.add(m);
                      }
                    }
                  }

                  // Local sort by createdAt desc (if exists)
                  products.sort((a, b) {
                    final ma = a['createdAt'];
                    final mb = b['createdAt'];
                    final ia = (ma is int) ? ma : int.tryParse('$ma') ?? 0;
                    final ib = (mb is int) ? mb : int.tryParse('$mb') ?? 0;
                    return ib.compareTo(ia);
                  });

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    children: products.map((data) {
                      final priceRaw = data['price'];
                      final origRaw = data['originalPrice'];

                      final price = (priceRaw is int)
                          ? priceRaw
                          : int.tryParse('$priceRaw') ?? 0;

                      final originalPrice = (origRaw == null)
                          ? null
                          : (origRaw is int
                          ? origRaw
                          : int.tryParse('$origRaw'));

                      return _ProductCard(
                        name: (data['name'] ?? '').toString(),
                        img: (data['imgUrl'] ?? '').toString(),
                        detail: (data['detail'] ?? '').toString(),
                        price: price,
                        originalPrice: originalPrice,
                        description: (data['description'] ?? '') as String?,
                        productId: data['id']?.toString(),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip(this.label, {this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF4B8BFF) : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? const Color(0xFF4B8BFF) : Colors.grey.shade400,
          width: selected ? 1.4 : 1,
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: chip,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name, img, detail;
  final int price;
  final int? originalPrice;

  // Forwarded to detail
  final String? description;
  final String? productId;

  const _ProductCard({
    required this.name,
    required this.img,
    required this.detail,
    required this.price,
    this.originalPrice,
    this.description,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 60) / 2;
    final imageSize = cardWidth;

    final favItem = FavouriteItem(
      image: img,
      title: name,
      desc: detail,
      price: price.toString(),
    );

    final isNetwork = img.startsWith('http');
    final hasImg = img.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopProductDetailScreen(
              img: img,
              name: name,
              detail: detail,
              price: price,
              originalPrice: originalPrice,
              description: description,
              productId: productId, // for optional fresh fetch in detail
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 14, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: hasImg
                  ? (isNetwork
                  ? Image.network(
                img,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                img,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ))
                  : Container(
                width: imageSize,
                height: imageSize,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.shopping_bag,
                    color: Colors.grey, size: 36),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Consumer<FavouritesProvider>(
                  builder: (context, favProvider, _) {
                    final isFavorite = favProvider.isFavourite(favItem);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 22,
                      ),
                      onPressed: () => favProvider.toggleFavourite(favItem),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (originalPrice != null && originalPrice! > price)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '\$${originalPrice}',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
