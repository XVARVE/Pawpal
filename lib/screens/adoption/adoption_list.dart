import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawpal/screens/adoption/adoption_map_screen.dart';
import 'adoption_detail.dart';

class AdoptionListScreen extends StatefulWidget {
  @override
  State<AdoptionListScreen> createState() => _AdoptionListScreenState();
}

class _AdoptionListScreenState extends State<AdoptionListScreen> {
  final filters = ["All", "Cat", "Dog", "Turtle", "Bird", "Rabbit"];
  int selectedFilter = 0;

  static const int _limit = 120;

  /// Build RTDB query:
  /// - "All": sort client-side by createdAt desc
  /// - Specific type: use species == filter server-side for efficiency
  Query _buildQuery() {
    final petsRef = FirebaseDatabase.instance.ref('pets');
    final f = filters[selectedFilter];

    if (f == 'All') {
      return petsRef.orderByChild('createdAt').limitToLast(_limit);
    } else {
      return petsRef.orderByChild('species').equalTo(f).limitToLast(_limit);
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              // fall back to home if this screen was opened as the first route
              nav.pushNamedAndRemoveUntil('/home', (route) => false);
              // If you adopted the typed router: use Routes.home instead of '/home'
              // nav.pushNamedAndRemoveUntil(Routes.home, (route) => false);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StreamBuilder<DatabaseEvent>(
          stream: _buildQuery().onValue,
          builder: (context, snap) {
            final headerTop = <Widget>[
              const SizedBox(height: 2),
              const Text(
                "Adopt",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black),
              ),
              const SizedBox(height: 3),
              Text(
                "Find the best pet",
                style: TextStyle(fontSize: 15.5, color: Colors.black.withOpacity(0.8)),
              ),
              const SizedBox(height: 17),

              // Search (visual only)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Dog",
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final bool selected = selectedFilter == i;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF4B8BFF) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? const Color(0xFF4B8BFF) : const Color(0xFFAAA7B2),
                            width: 1.3,
                          ),
                        ),
                        child: Text(
                          filters[i],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
            ];

            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  ...headerTop,
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            final data = snap.data?.snapshot.value;
            if (data == null) {
              return ListView(
                children: [
                  ...headerTop,
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No pets yet!'),
                    ),
                  ),
                ],
              );
            }

            // RTDB returns Map<dynamic, dynamic>
            final raw = Map<dynamic, dynamic>.from(data as Map);
            final entries = raw.entries.map((e) {
              final m = Map<String, dynamic>.from(e.value as Map);
              return {
                'id'        : e.key.toString(),
                'img'       : (m['imgUrl'] ?? '') as String,
                'name'      : (m['name'] ?? '') as String,
                'breed'     : (m['breed'] ?? '') as String,
                'age'       : (m['age'] ?? '') as String,
                'gender'    : (m['gender'] ?? '') as String,
                'species'   : (m['species'] ?? '') as String,
                'weight'    : (m['weight'] ?? '') as String? ?? '',
                'desc'      : (m['description'] ?? '') as String? ?? '',
                'typePet'   : (m['typePet'] ?? '') as String? ?? '',
                'createdAt' : (m['createdAt'] ?? 0),
              };
            }).toList();

            // Sort newest first by createdAt (int timestamp)
            entries.sort((a, b) {
              final ams = (a['createdAt'] ?? 0) is int ? a['createdAt'] as int : 0;
              final bms = (b['createdAt'] ?? 0) is int ? b['createdAt'] as int : 0;
              return bms.compareTo(ams);
            });

            final sel = filters[selectedFilter];
            final isAll = sel == 'All';

            // Client-side safety filter for species
            List<Map<String, dynamic>> filtered = entries;
            if (!isAll) {
              filtered = filtered.where((p) {
                final species = (p['species'] ?? '') as String;
                if (species.isNotEmpty) return species == sel;
                final t = sel.toLowerCase(); // fallback: try match name/breed
                return (p['breed'] as String).toLowerCase().contains(t) ||
                    (p['name']  as String).toLowerCase().contains(t);
              }).toList();
            }

            // If "All": split into first 2 + Latest; else: show header(title) + full list (no "Nearest place")
            final section1 = isAll ? filtered.take(2).toList() : <Map<String, dynamic>>[];
            final sectionRest = isAll ? filtered.skip(2).toList() : filtered;

            return ListView(
              children: [
                ...headerTop,

                if (isAll) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Nearest place",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdoptionMapScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(20, 20),
                          textStyle: const TextStyle(fontSize: 15.2, fontWeight: FontWeight.w500),
                        ),
                        child: const Text("See more"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Show two cards for nearest (section1)
                  Wrap(
                    spacing: 12,
                    runSpacing: 18,
                    children: [
                      for (final p in section1)
                        PetCard(
                          img: p['img'] as String,
                          name: p['name'] as String,
                          age: p['age'] as String,
                          gender: p['gender'] as String,
                          isFavorite: false,
                          onFavorite: () {},
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdoptionDetailScreen(
                                  images: [(p['img'] as String)].where((s) => s.isNotEmpty).toList(),
                                  name: p['name'] as String,
                                  breed: p['breed'] as String,
                                  age: p['age'] as String,
                                  gender: p['gender'] as String,
                                  weight: ((p['weight'] as String).isNotEmpty) ? p['weight'] as String : '3 Kg',
                                  desc: ((p['desc'] as String).isNotEmpty) ? p['desc'] as String : 'No description provided.',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const _SectionHeader(title: "Latest"),
                  const SizedBox(height: 12),
                ] else ...[
                  _SectionHeader(title: sel), // e.g. "Dog", "Cat"
                  const SizedBox(height: 12),
                ],

                // Main list (for "All": the rest; for specific filter: full filtered list)
                Wrap(
                  spacing: 12,
                  runSpacing: 18,
                  children: [
                    for (final p in sectionRest)
                      PetCard(
                        img: p['img'] as String,
                        name: p['name'] as String,
                        age: p['age'] as String,
                        gender: p['gender'] as String,
                        isFavorite: false,
                        onFavorite: () {},
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdoptionDetailScreen(
                                images: [(p['img'] as String)].where((s) => s.isNotEmpty).toList(),
                                name: p['name'] as String,
                                breed: p['breed'] as String,
                                age: p['age'] as String,
                                gender: p['gender'] as String,
                                weight: ((p['weight'] as String).isNotEmpty) ? p['weight'] as String : '3 Kg',
                                desc: ((p['desc'] as String).isNotEmpty) ? p['desc'] as String : 'No description provided.',
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5)),
        const Text("See more",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.2)),
      ],
    );
  }
}

class PetCard extends StatelessWidget {
  final String img;
  final String name;
  final String age;
  final String gender;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback? onTap;
  final dynamic price; // Optional

  const PetCard({
    Key? key,
    required this.img,
    required this.name,
    required this.age,
    required this.gender,
    required this.isFavorite,
    required this.onFavorite,
    this.onTap,
    this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNetwork = img.startsWith('http');
    final hasImg = img.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: hasImg
                  ? (isNetwork
                  ? Image.network(img, width: 150, height: 150, fit: BoxFit.cover)
                  : Image.asset(img, width: 150, height: 150, fit: BoxFit.cover))
                  : Container(
                width: 150,
                height: 150,
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
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
            Text(age, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Text(gender, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            if (price != null)
              Text('\$${price}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
