import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawpal/screens/vet/vet_appointment_success_screen.dart';

class VetAppointmentSummaryScreen extends StatelessWidget {
  const VetAppointmentSummaryScreen({
    super.key,
    required this.vetId,
    this.serviceTitle,
    this.servicePrice,
    this.applicationFee = 0.5,
    this.dateLabel,
    this.timeSlot,
    this.appointmentCode,
  });

  /// RTDB id for /vets/{vetId}
  final String vetId;

  /// Optional details from the appointment flow
  final String? serviceTitle;   // e.g., "Consultation"
  final double? servicePrice;   // e.g., 10.0
  final double applicationFee;  // default 0.5
  final String? dateLabel;      // e.g., "Mon, Aug 25" or "Today"
  final String? timeSlot;       // e.g., "9:00 AM - 09:30 AM"
  final String? appointmentCode;

  static const Color kBlue = Color(0xFF4B8BFF);
  static const Color kDivider = Color(0xFFEAEAEA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Sticky Sub Total + Checkout
      bottomNavigationBar: _BottomBar(
        serviceTitle: serviceTitle ?? 'Consultation',
        servicePrice: servicePrice ?? 10.0,
        applicationFee: applicationFee,
      ),

      appBar: AppBar(
        title: const Text(
          'Appointment Summary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        top: false,
        child: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('vets/$vetId').onValue,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load vet: ${snap.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final data = snap.data?.snapshot.value;
            if (data == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Vet not found.'),
                ),
              );
            }

            final vet = Map<String, dynamic>.from(data as Map);
            final name = (vet['name'] ?? '') as String;
            final clinic = (vet['clinic'] ?? '') as String;

            // Support either RTDB 'imgUrl' or a local 'img' path
            final imgPath = (vet['img'] ?? vet['imgUrl'] ?? '') as String;
            final ImageProvider avatarProvider = imgPath.isEmpty
                ? const AssetImage('assets/images/Vet1.jpg')
                : (imgPath.startsWith('http')
                ? NetworkImage(imgPath)
                : AssetImage(imgPath) as ImageProvider);

            // Derived values
            final String svcTitle = serviceTitle ?? 'Consultation';
            final double svcPrice = servicePrice ?? 10.0;
            final double fee = applicationFee;
            final double total = svcPrice + fee;

            final String dateText = dateLabel ?? '';
            final String timeText = timeSlot ?? '';
            final String apptCode = appointmentCode ?? _defaultAppointmentCode(vet);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                // ===== Information Veterinarian =====
                const Text('Information Veterinarian',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: avatarProvider,
                      radius: 26,
                      backgroundColor: const Color(0xFFEFF3FF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5)),
                          const SizedBox(height: 2),
                          Text(clinic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('No Appointment', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text(apptCode, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: kDivider),
                const SizedBox(height: 18),

                // ===== Order Detail =====
                const Text('Order Detail',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 10),

                _KVRow(label: svcTitle, value: '\$${svcPrice.toStringAsFixed(2)}'),
                _KVRow(label: 'Application Free', value: '\$${fee.toStringAsFixed(2)}'),
                if (dateText.isNotEmpty || timeText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  if (dateText.isNotEmpty) _KVRow(label: 'Date', value: dateText),
                  if (timeText.isNotEmpty) _KVRow(label: 'Time', value: timeText),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1, color: kDivider),
                const SizedBox(height: 18),

                // ===== Contact Customer =====
                const Text('Contact Customer',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 10),
                const Text('Amel Jane', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('+9905-1950', style: TextStyle(color: Colors.black87)),

                const SizedBox(height: 18),
                const Divider(height: 1, color: kDivider),
                const SizedBox(height: 18),

                // ===== Payment Method =====
                const Text('Payment Method',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black87, width: 1), // black border
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text('Paypal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _defaultAppointmentCode(Map v) {
    final ts = v['createdAt'];
    if (ts is num) {
      final s = ts.toString();
      final last = s.length >= 3 ? s.substring(s.length - 3) : s;
      return 'AP$last';
    }
    return 'AP021';
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.serviceTitle,
    required this.servicePrice,
    required this.applicationFee,
  });

  final String serviceTitle;
  final double servicePrice;
  final double applicationFee;

  static const Color kBlue = Color(0xFF4B8BFF);
  static const Color kDivider = Color(0xFFEAEAEA);

  @override
  Widget build(BuildContext context) {
    final total = servicePrice + applicationFee;
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kDivider)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sub Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(color: kBlue, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VetAppointmentSuccessScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
