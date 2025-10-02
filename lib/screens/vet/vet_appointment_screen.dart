import 'package:flutter/material.dart';
import 'vet_appointment_summary_screen.dart'; // update path if needed

class VetAppointmentScreen extends StatefulWidget {
  const VetAppointmentScreen({
    super.key,
    required this.vetId, // <-- pass the RTDB key for /vets/{vetId}
  });

  final String vetId;

  @override
  State<VetAppointmentScreen> createState() => _VetAppointmentScreenState();
}

class _VetAppointmentScreenState extends State<VetAppointmentScreen> {
  int selectedService = 0;
  int selectedDate = 0;
  int selectedTime = 0;

  DateTime? _pickedDate; // custom date from date picker (overrides chips when set)

  final services = const [
    {'title': 'Consultation', 'price': 10},
    {'title': 'Sterilization', 'price': 17},
    {'title': 'Vacination', 'price': 15}, // spelling per screenshot
  ];

  final dates = const [
    {'label': 'Today', 'date': 'Aug 17'},
    {'label': 'Thursday', 'date': 'Aug 18'},
    {'label': 'Friday', 'date': 'Aug 19'},
    {'label': 'Monday', 'date': 'Aug 22'},
  ];

  final times = const [
    {'time': '9:00 AM - 09:30 AM', 'available': true},
    {'time': '9:30 AM - 10:00 AM', 'available': false},
    {'time': '10:00 AM - 10:30 AM', 'available': false},
  ];

  static const purple = Color(0xFF6C4CBF);
  static const blue = Color(0xFF4B8BFF);

  String _formatPicked(DateTime d) {
    // Example: Mon, Aug 25
    final wd = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday - 1];
    const mons = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final mon = mons[d.month - 1];
    return '$wd, $mon ${d.day}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _pickedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Select Appointment Date',
    );
    if (picked != null) {
      setState(() {
        _pickedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Derived date label to send forward
    final selectedDateLabel = _pickedDate != null
        ? _formatPicked(_pickedDate!)
        : dates[selectedDate]['label'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      // Bottom fixed CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the summary page, forwarding the vetId and selections
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VetAppointmentSummaryScreen(
                    vetId: widget.vetId,
                    serviceTitle: services[selectedService]['title'] as String,
                    servicePrice: (services[selectedService]['price'] as num).toDouble(),
                    dateLabel: selectedDateLabel,
                    timeSlot: times[selectedTime]['time'] as String,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              'Confirm  Appointment',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Appointment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          // ===== Select Service =====
          const Text('Select Service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(services.length, (i) {
              final s = services[i];
              final selected = selectedService == i;
              return Expanded(
                child: _BoxButton(
                  selected: selected,
                  onTap: () => setState(() => selectedService = i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s['title'].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${s['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).insertSeparators(const SizedBox(width: 12)),
          ),

          const SizedBox(height: 28),

          // ===== Select Date =====
          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 14),

          // Keep the exact row layout — with an extra calendar chip appended.
          Row(
            children: [
              ...List.generate(dates.length, (i) {
                final d = dates[i];
                final selected = _pickedDate == null && selectedDate == i;
                return Expanded(
                  child: _BoxButton(
                    selected: selected,
                    onTap: () => setState(() {
                      _pickedDate = null; // go back to preset chips
                      selectedDate = i;
                    }),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d['label'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d['date'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).insertSeparators(const SizedBox(width: 12)),

              // Small gap then the calendar-picker chip (same size/shape)
              const SizedBox(width: 12),
              Expanded(
                child: _BoxButton(
                  selected: _pickedDate != null,
                  onTap: _pickDate,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pickedDate != null ? 'Custom' : 'Pick Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _pickedDate != null ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16,
                              color: Colors.black87),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _pickedDate != null ? _formatPicked(_pickedDate!) : 'Calendar',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: _pickedDate != null ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ===== Working Time =====
          const Text('Working Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          ...List.generate(times.length, (i) {
            final t = times[i];
            final selected = selectedTime == i;
            final available = t['available'] as bool;
            return _TimeRow(
              time: t['time'] as String,
              available: available,
              selected: selected,
              onTap: available ? () => setState(() => selectedTime = i) : null,
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Reusable box button used for service and date selections.
class _BoxButton extends StatelessWidget {
  final bool selected;
  final Widget child;
  final VoidCallback? onTap;
  const _BoxButton({required this.selected, required this.child, this.onTap});

  static const purple = Color(0xFF6C4CBF);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? purple : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? purple : const Color(0xFFE6E6E6)),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// Time row without check/tick:
class _TimeRow extends StatelessWidget {
  final String time;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeRow({
    required this.time,
    required this.available,
    required this.selected,
    this.onTap,
  });

  static const blue = Color(0xFF4B8BFF);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // disabled if null
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Custom circle indicator (no tick)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? blue : Colors.transparent,
                border: Border.all(
                  color: selected ? blue : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            Text(
              available ? 'Available' : 'Not Available',
              style: TextStyle(
                color: available ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Small utility to add separators in a List<Widget> ----
extension on List<Widget> {
  List<Widget> insertSeparators(Widget separator) {
    if (isEmpty) return this;
    final withSep = <Widget>[];
    for (var i = 0; i < length; i++) {
      withSep.add(this[i]);
      if (i != length - 1) withSep.add(separator);
    }
    return withSep;
  }
}
