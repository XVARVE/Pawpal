import 'package:flutter/material.dart';
// RTDB instead of Firestore
import 'package:firebase_database/firebase_database.dart';

import 'package:pawpal/drawers/shop_filter_drawer.dart';
import 'package:pawpal/screens/shop/shop_pet_detail.dart';
import 'package:pawpal/widgets/shop_search_screen.dart';

class ShopPetScreen extends StatefulWidget {
  final PetFilter? filters;
  const ShopPetScreen({Key? key, this.filters}) : super(key: key);

  @override
  State<ShopPetScreen> createState() => _ShopPetScreenState();
}

class _ShopPetScreenState extends State<ShopPetScreen> {
  String? _searchQuery;

  /// Currently selected type chip (“All”, “Cat”, “Dog”, “Turtle”, “Bird”, “Rabbit”)
  late String _selectedTypePet;

  @override
  void initState() {
    super.initState();
    // Initialize from incoming filters (typePet preferred), fallback to “All”
    final incoming = widget.filters?.typePet ?? widget.filters?.species;
    _selectedTypePet = (incoming != null && incoming.isNotEmpty) ? incoming : 'All';
  }

  /// Build a Realtime Database query based on search/species.
  /// NOTE: RTDB allows only one orderBy per query; we choose the most relevant:
  /// - If searching: orderByChild('nameLower') + startAt/endAt
  /// - Else if species filter (not All): orderByChild('species') + equalTo
  /// - Else: orderByChild('createdAt') (descending simulated by local sort)
  Query _buildQuery() {
    final db = FirebaseDatabase.instance.ref('pets');

    // Search wins (must orderBy the same child)
    if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
      final s = _searchQuery!.trim().toLowerCase();
      return db.orderByChild('nameLower').startAt(s).endAt('$s\uf8ff');
    }

    // Otherwise, filter by species if provided
    if (_selectedTypePet != 'All') {
      return db.orderByChild('species').equalTo(_selectedTypePet);
    }

    // Default: by createdAt (we’ll sort descending locally)
    return db.orderByChild('createdAt');
  }

  void _applyChip(String label) {
    if (_selectedTypePet == label) return; // no-op
    setState(() {
      _selectedTypePet = label;
      // Clear search so the chip filter takes effect immediately.
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
            // --- Search bar (unchanged layout) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () async {
                  final query = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => ShopSearchScreen()),
                  );
                  if (query != null) {
                    setState(() => _searchQuery = query);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: _searchQuery ?? ''),
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Food for rabbit',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        borderSide: BorderSide(
                          color: Color(0xFF4B8BFF),
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // --- Pet type chips (now interactive) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    'All',
                    selected: _selectedTypePet == 'All',
                    onTap: () => _applyChip('All'),
                  ),
                  _CategoryChip(
                    'Cat',
                    selected: _selectedTypePet == 'Cat',
                    onTap: () => _applyChip('Cat'),
                  ),
                  _CategoryChip(
                    'Dog',
                    selected: _selectedTypePet == 'Dog',
                    onTap: () => _applyChip('Dog'),
                  ),
                  _CategoryChip(
                    'Turtle',
                    selected: _selectedTypePet == 'Turtle',
                    onTap: () => _applyChip('Turtle'),
                  ),
                  _CategoryChip(
                    'Bird',
                    selected: _selectedTypePet == 'Bird',
                    onTap: () => _applyChip('Bird'),
                  ),
                  _CategoryChip(
                    'Rabbit',
                    selected: _selectedTypePet == 'Rabbit',
                    onTap: () => _applyChip('Rabbit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Count + Grid (driven by RTDB stream)
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _buildQuery().onValue,
                builder: (context, snapshot) {
                  // Default header (count will be computed below)
                  Widget header(int count) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$count Pet${count == 1 ? '' : 's'} Available",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(0),
                        const SizedBox(height: 10),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }

                  final data = snapshot.data?.snapshot.value;

                  // RTDB can return null or a Map of maps
                  if (data == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(0),
                        const SizedBox(height: 10),
                        const Center(child: Text('No pets found')),
                      ],
                    );
                  }

                  // Convert RTDB map -> List<Map<String, dynamic>>
                  // Structure: { "-Nxy123": {name:..., ...}, ... }
                  final List<Map<String, dynamic>> rawPets = [];
                  if (data is Map) {
                    data.forEach((key, value) {
                      if (value is Map) {
                        final m = Map<String, dynamic>.from(value);
                        m['id'] = key;
                        rawPets.add(m);
                      }
                    });
                  }

                  // Local sort by createdAt desc if present
                  rawPets.sort((a, b) {
                    final ma = a['createdAt'];
                    final mb = b['createdAt'];
                    final ia = (ma is int) ? ma : int.tryParse('$ma') ?? 0;
                    final ib = (mb is int) ? mb : int.tryParse('$mb') ?? 0;
                    return ib.compareTo(ia);
                  });

                  // Map to the shape your UI expects
                  final pets = rawPets.map((m) {
                    return {
                      'name': (m['name'] ?? '').toString(),
                      'img': (m['imgUrl'] ?? '').toString(),
                      'price': m['price'] ?? 0, // may not exist for pets; default 0
                      'age': (m['age'] ?? '').toString(),
                      'gender': (m['gender'] ?? '').toString(),
                      // for detail page
                      'breed': (m['breed'] ?? '') as String?,
                      'weight': (m['weight'] ?? '') as String?,
                      'description': (m['description'] ?? '') as String?,
                    };
                  }).toList();

                  final count = pets.length;

                  if (count == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(0),
                        const SizedBox(height: 10),
                        const Center(child: Text('No pets found')),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      header(count),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gridItemWidth =
                                (constraints.maxWidth / 2) - 14;
                            // keep proportions as before
                            final gridItemHeight = gridItemWidth * 1.17;

                            return GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 8,
                              children: pets.map((pet) {
                                final priceVal = pet['price'];
                                final price = (priceVal is int)
                                    ? priceVal
                                    : int.tryParse('$priceVal') ?? 0;
                                return _PetCard(
                                  name: pet['name'] as String,
                                  img: pet['img'] as String,
                                  price: price,
                                  age: pet['age'] as String,
                                  gender: pet['gender'] as String,
                                  breed: pet['breed'] as String?,
                                  weight: pet['weight'] as String?,
                                  description: pet['description'] as String?,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
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

// Category chip widget — now tappable
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip(
      this.label, {
        this.selected = false,
        this.onTap,
      });

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

    // Keep exact layout, just make entire chip tappable
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

// Card (layout identical) with network/asset support + forwards extra fields
class _PetCard extends StatefulWidget {
  final String name, img, age, gender;
  final int price;
  final String? breed;        // NEW
  final String? weight;       // NEW
  final String? description;  // NEW

  const _PetCard({
    required this.name,
    required this.img,
    required this.price,
    required this.age,
    required this.gender,
    this.breed,
    this.weight,
    this.description,
  });

  @override
  State<_PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<_PetCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 60) / 2;
    final imageSize = cardWidth;

    final isNetwork = widget.img.startsWith('http');
    final hasImg = widget.img.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopPetDetailScreen(
              img: widget.img,
              name: widget.name,
              age: widget.age,
              gender: widget.gender,
              price: widget.price,
              breed: widget.breed,
              weight: widget.weight,
              description: widget.description,
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
                widget.img,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                widget.img,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ))
                  : Container(
                width: imageSize,
                height: imageSize,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.pets, color: Colors.grey, size: 36),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => isFavorite = !isFavorite),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
            Text(widget.age,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            Text(widget.gender,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(
              '\$${widget.price}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
