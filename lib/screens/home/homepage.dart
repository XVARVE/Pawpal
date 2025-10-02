import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pawpal/screens/shop/favourites_screen.dart';
import 'package:pawpal/widgets/add_pet_screen.dart';
import 'package:pawpal/widgets/home_widgets.dart';

// RTDB
import 'package:firebase_database/firebase_database.dart';
import 'package:pawpal/services/rtdb_service.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final List<Map<String, String>> insights = const [
    {'img': 'assets/images/Insight1.jpg', 'title': 'How to care for dog hair'},
    {'img': 'assets/images/Insight1.jpg', 'title': '5 tips for healthy cats'},
  ];

  void _goToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FC),
      body: Stack(
        children: [
          // Top Gradient Background
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7AC3FE), Color(0xFFE5D3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),

          SafeArea(
            child: ListView(
              children: [
                // Header Row — RTDB
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12),
                  child: uid == null
                      ? _HeaderRow(
                    name: 'Guest',
                    photoProvider: const AssetImage('assets/user.jpg'),
                    onProfileTap: () => _goToProfile(context),
                  )
                      : StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance.ref('users/$uid').onValue,
                    builder: (context, snap) {
                      String name = '...';
                      ImageProvider avatar = const AssetImage('assets/user.jpg');

                      final data = snap.data?.snapshot.value;
                      if (data is Map) {
                        final map = Map<String, dynamic>.from(data as Map);
                        final n = (map['name'] as String?)?.trim();
                        final p = (map['photoUrl'] as String?)?.trim();
                        if (n != null && n.isNotEmpty) name = n;
                        if (p != null && p.isNotEmpty) {
                          avatar = NetworkImage(p);
                        }
                      }

                      return _HeaderRow(
                        name: name,
                        photoProvider: avatar,
                        onProfileTap: () => _goToProfile(context),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 120),

                // Nav Card — FLOATS at gradient edge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    transform: Matrix4.translationValues(0, -36, 0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 5,
                      shadowColor: const Color(0xFF7AC3FE).withOpacity(0.13),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Entire tile tappable + inner onTap restored
                            _TapAll(
                              onTap: () => Navigator.pushNamed(context, '/shop'),
                              child: NavItem(
                                icon: 'assets/icons/Shop.png',
                                label: "Shop",
                                onTap: () => Navigator.pushNamed(context, '/shop'),
                              ),
                            ),
                            _TapAll(
                              onTap: () => Navigator.pushNamed(context, '/adoption'),
                              child: NavItem(
                                icon: 'assets/icons/Adoption.png',
                                label: "Adoption",
                                onTap: () => Navigator.pushNamed(context, '/adoption'),
                              ),
                            ),
                            _TapAll(
                              onTap: () => Navigator.pushNamed(context, '/veterinarian'),
                              child: NavItem(
                                icon: 'assets/icons/Veterinarian.png',
                                label: "Veterinarian",
                                onTap: () => Navigator.pushNamed(context, '/veterinarian'),
                              ),
                            ),
                            // Keep as-is (no route given)
                            const NavItem(icon: 'assets/icons/Treatment.png', label: "Treatment"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Insight For You
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: const [
                      Text('Insight For You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Spacer(),
                      Text('See more',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: insights.length,
                    itemBuilder: (context, i) {
                      final insight = insights[i];
                      return Container(
                        margin: const EdgeInsets.only(right: 14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            insight['img']!,
                            height: 150,
                            width: 316,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Latest Adoptions — See more -> /adoption
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Text('Latest Adoptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/adoption'),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Text(
                            'See more',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // RTDB latest pets
                SizedBox(
                  height: 180,
                  child: StreamBuilder<DatabaseEvent>(
                    stream: RTDBService.latestPets(limit: 10),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return const Center(child: Text('No pets yet!'));
                      }

                      final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      final entries = raw.entries.toList()
                        ..sort((a, b) {
                          final ams = (a.value['createdAt'] ?? 0) as int;
                          final bms = (b.value['createdAt'] ?? 0) as int;
                          return bms.compareTo(ams); // newest first
                        });

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: entries.length,
                        itemBuilder: (context, i) {
                          final e = entries[i];
                          final pet = Map<String, dynamic>.from(e.value as Map);
                          return PetAdoptCard(
                            img: (pet['imgUrl'] ?? '') as String,
                            name: (pet['name'] ?? 'Pet') as String,
                            age: (pet['age'] ?? '') as String,
                            gender: (pet['gender'] ?? '') as String,
                            isFavorite: false,
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4B8BFF),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetScreen()));
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String name;
  final ImageProvider photoProvider;
  final VoidCallback onProfileTap;

  const _HeaderRow({
    Key? key,
    required this.name,
    required this.photoProvider,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(28),
          child: CircleAvatar(radius: 28, backgroundImage: photoProvider),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: onProfileTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello, Good Morning!",
                style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w400),
              ),
              Text(
                name.isEmpty ? 'User' : name,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.search, color: Colors.black, size: 26),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FavouritesScreen()));
          },
          child: const Icon(Icons.favorite_border, color: Colors.black, size: 27),
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, color: Colors.black, size: 27),
            Positioned(
              right: -2,
              top: 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

/// Wrap any nav tile so the whole (icon + label) surface is tappable.
/// Keeps layout identical by not adding extra padding/margins.
class _TapAll extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapAll({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}
