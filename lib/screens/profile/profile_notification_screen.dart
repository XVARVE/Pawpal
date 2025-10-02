import 'package:flutter/material.dart';

class ProfileNotificationsScreen extends StatelessWidget {
  final notifications = [
    {
      'icon': Icons.shopping_bag,
      'color': Colors.green,
      'title': 'Purchase Order : Makanan Hewan \$10',
      'time': '8 minutes ago',
    },
    {
      'icon': Icons.event_available,
      'color': Colors.purple,
      'title': 'Scheduled appointments with pet owners accepted',
      'time': '12 August 2022',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final chips = ["All", "Latest", "Purchase", "Adopt"];
    int selectedChip = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: List.generate(chips.length, (i) {
                return ChoiceChip(
                  label: Text(chips[i]),
                  selected: i == selectedChip,
                  selectedColor: Color(0xFF4B8BFF),
                  labelStyle: TextStyle(
                    color: i == selectedChip ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (v) {},
                );
              }),
            ),
            SizedBox(height: 18),
            ...notifications.map((note) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 14),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (note['color'] as Color).withOpacity(0.12),
                  child: Icon(note['icon'] as IconData, color: note['color'] as Color),
                ),
                title: Text(note['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(note['time']!, style: TextStyle(color: Colors.black54, fontSize: 13)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
