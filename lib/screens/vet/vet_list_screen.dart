import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pawpal/services/rtdb_service.dart';

import 'vet_profile_screen.dart';

class VetListScreen extends StatelessWidget {
  const VetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top gradient header
          Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7AC3FE), Color(0xFFE5D3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
          ),

          // Page content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                       IconButton(
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
                      const SizedBox(width: 4),
                      const Text(
                        'Veterinarian',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      // Banner (kept as-is per earlier design)
                      Transform.translate(
                        offset: const Offset(0, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 220,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/VetBanner.jpg'),
                                fit: BoxFit.fill,
                              ),
                              color: Color(0xFF28C7C0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Nearest Veterinarian',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('See more',
                              style: TextStyle(color: Color(0xFF6B6B6B), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ---------- Vets from RTDB ----------
                      StreamBuilder<DatabaseEvent>(
                        stream: RTDBService.latestVets(limit: 20),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snap.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text('Failed to load vets: ${snap.error}',
                                  style: const TextStyle(color: Colors.red)),
                            );
                          }

                          final raw = snap.data?.snapshot.value;
                          if (raw == null) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('No veterinarians found.'),
                            );
                          }

                          // RTDB returns a map of id -> data
                          final map = Map<String, dynamic>.from(raw as Map);
                          // Convert to list and sort by createdAt DESC
                          final vets = map.entries.map((e) {
                            final m = Map<String, dynamic>.from(e.value);
                            m['id'] = e.key;
                            return m;
                          }).toList()
                            ..sort((a, b) {
                              final ca = (a['createdAt'] ?? 0) as num;
                              final cb = (b['createdAt'] ?? 0) as num;
                              return cb.compareTo(ca);
                            });

                          return Column(
                            children: vets.map((vet) {
                              final img = (vet['imgUrl'] ?? '') as String;
                              final name = (vet['name'] ?? '') as String;
                              final clinic = (vet['clinic'] ?? '') as String;

                              // distance support: either 'distance' string or numeric 'distanceKm'
                              String distance = (vet['distance'] ?? '') as String;
                              if (distance.isEmpty && vet['distanceKm'] != null) {
                                final d = (vet['distanceKm'] as num).toDouble();
                                distance = '${d.toStringAsFixed(d < 1 ? 2 : 1)} Km';
                              }

                              return _VetTile(
                                name: name,
                                clinic: clinic,
                                img: img,
                                distance: distance,
                                onTap: () {
                                  // ➜ Go to VetProfileScreen and pass the vet data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VetProfileScreen(
                                        vet: {
                                          'id': vet['id'],
                                          'name': name,
                                          'clinic': clinic,
                                          'img': img,
                                          'experience': (vet['experience'] ?? '5 Years') as String,
                                          'ratings': (vet['ratings'] ?? 4.9).toString(),
                                          'workingTime': (vet['workingTime'] ?? 'Monday - Friday') as String,
                                          'hours': (vet['hours'] ?? '9:00 AM - 5.00 PM') as String,
                                          'location': (vet['location'] ?? clinic) as String,
                                          'distance': distance,
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
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

class _VetTile extends StatelessWidget {
  final String name;
  final String clinic;
  final String img; // can be network or asset path
  final String distance;
  final VoidCallback onTap;

  const _VetTile({
    required this.name,
    required this.clinic,
    required this.img,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarProvider;
    if (img.startsWith('http')) {
      avatarProvider = NetworkImage(img);
    } else if (img.isNotEmpty) {
      avatarProvider = AssetImage(img);
    } else {
      avatarProvider = const AssetImage('assets/images/Vet1.jpg');
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFEFF3FF),
                child: Image(
                  image: avatarProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(clinic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              distance,
              style: const TextStyle(color: Color(0xFF6B6B6B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
