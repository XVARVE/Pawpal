import 'package:flutter/material.dart';
import 'package:pawpal/screens/vet/vet_appointment_screen.dart';

class VetProfileScreen extends StatelessWidget {
  final Map<String, dynamic> vet;
  const VetProfileScreen({super.key, required this.vet});

  @override
  Widget build(BuildContext context) {
    final name = (vet['name'] ?? '') as String;
    final clinic = (vet['clinic'] ?? '') as String;
    final img = (vet['img'] ?? '') as String;
    final experience = (vet['experience'] ?? '5 Years') as String;
    final ratings = (vet['ratings'] ?? '4,9') as String; // keep comma like screenshot
    final workingTime = (vet['workingTime'] ?? 'Monday - Friday') as String;
    final hours = (vet['hours'] ?? '9:00 AM - 5.00 PM') as String;
    final location = (vet['location'] ?? clinic) as String;

    return Scaffold(
      backgroundColor: Colors.white,
      // Fixed bottom CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {
                // make sure your profile screen was launched with a vet map that includes 'id'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VetAppointmentScreen(vetId: vet['id'] as String),
                  ),
                );
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B8BFF),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              'Create Appointment',
              style: TextStyle(
                color: Colors.white, // white text
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER (gradient ends at the white divider line) =====
            Stack(
              children: [
                // Gradient background with rounded bottom
                Container(
                  height: 235, // tuned so it ends right at the divider
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7AC3FE), Color(0xFFE5D3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                  ),
                ),

                // Content over the gradient
                Column(
                  children: [
                    // Top bar (back + centered title)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'Verinarian Profile', // matches screenshot text
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Row: bigger avatar + info aligned next to it
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Bigger photo with white ring
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: CircleAvatar(
                              radius: 46, // bigger avatar
                              backgroundImage: AssetImage(img),
                              backgroundColor: const Color(0xFFEFF3FF),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info column aligned with the photo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Experience',
                                              style: TextStyle(fontSize: 14, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text(
                                            experience,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Ratings',
                                              style: TextStyle(fontSize: 14, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text(
                                            ratings,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // White divider line exactly at the bottom of the gradient
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: const Divider(height: 1, color: Color(0xFFEAEAEA)),
                ),
              ],
            ),

            // ===== BODY (pushed a little bit down) =====
            const SizedBox(height: 8), // push details down a bit
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Working Time
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: const Text(
                        'Working Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                              children: [
                                const TextSpan(text: 'Date\n'),
                                TextSpan(
                                  text: workingTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                              children: [
                                const TextSpan(text: 'Time\n'),
                                TextSpan(
                                  text: hours,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEAEAEA)),

                    // Location
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Name Clinic', style: TextStyle(color: Colors.black54, fontSize: 15)),
                          Text(
                            'View on map',
                            style: TextStyle(
                              color: Color(0xFF4B8BFF),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEAEAEA)),

                    // Service
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: const Text(
                        'Service',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: const [
                          _ServiceTile(label: 'Consultation', price: 10),
                          SizedBox(width: 12),
                          _ServiceTile(label: 'Sterilization', price: 17),
                          SizedBox(width: 12),
                          _ServiceTile(label: 'Vacination', price: 15), // spelling as in screenshot
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // extra breathing room above bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final int price;
  const _ServiceTile({required this.label, required this.price});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text('\$$price', style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
