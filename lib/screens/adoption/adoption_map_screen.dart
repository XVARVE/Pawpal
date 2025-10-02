import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: AdoptionMapScreen()));

final List<Map<String, String>> pets = [
  {
    'img': 'assets/images/Dog3.jpg',
    'name': 'Casper',
    'age': '1.5 Years',
    'gender': 'Male',
    'distance': '0.5 km',
    'time': '8-15 min',
  },
  {
    'img': 'assets/images/Cat4.jpg',
    'name': 'Lucky',
    'age': '1 Years',
    'gender': 'Male',
    'distance': '1.0 km',
    'time': '10-20 min',
  },
  {
    'img': 'assets/images/Dog4.jpg',
    'name': 'Thomas',
    'age': '0.9 Years',
    'gender': 'Male',
    'distance': '1.3 km',
    'time': '12-20 min',
  },
  {
    'img': 'assets/images/Dog5.jpg',
    'name': 'Muffin',
    'age': '1.5 Years',
    'gender': 'Female',
    'distance': '2.0 km',
    'time': '15-25 min',
  },
];

// Pin positions for each pet card
final List<Offset> pinOffsets = [
  Offset(50, 60),
  Offset(250, 100),
  Offset(130, 170),
  Offset(210, 220),
];

class AdoptionMapScreen extends StatefulWidget {
  @override
  State<AdoptionMapScreen> createState() => _AdoptionMapScreenState();
}

class _AdoptionMapScreenState extends State<AdoptionMapScreen> {
  int selectedPetIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button & search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.search, color: Colors.black38),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search Location",
                                hintStyle: TextStyle(color: Colors.black26, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map area with pins
            Expanded(
              child: Stack(
                children: [
                  Container(color: Colors.white),
                  for (int i = 0; i < pinOffsets.length; i++)
                    Positioned(
                      left: pinOffsets[i].dx,
                      top: pinOffsets[i].dy,
                      child: Icon(
                        Icons.location_pin,
                        size: 36,
                        color: selectedPetIndex == i
                            ? Color(0xFF4B8BFF)
                            : Colors.black38,
                      ),
                    ),
                ],
              ),
            ),
            // Pet card carousel at bottom
            Container(
              height: 210,
              margin: EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 18, right: 4),
                itemCount: pets.length,
                itemBuilder: (context, i) {
                  final pet = pets[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedPetIndex = i);
                    },
                    child: MapPetCard(
                      img: pet['img']!,
                      name: pet['name']!,
                      age: pet['age']!,
                      gender: pet['gender']!,
                      distance: pet['distance']!,
                      time: pet['time']!,
                      isSelected: selectedPetIndex == i,
                    ),
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

class MapPetCard extends StatelessWidget {
  final String img, name, age, gender, distance, time;
  final bool isSelected;

  const MapPetCard({
    Key? key,
    required this.img,
    required this.name,
    required this.age,
    required this.gender,
    required this.distance,
    required this.time,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 210,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.black.withOpacity(0.14)
                : Colors.black.withOpacity(0.07),
            blurRadius: isSelected ? 18 : 10,
            offset: Offset(0, 4),
          )
        ],
        border: isSelected
            ? Border.all(color: Color(0xFF4B8BFF), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top image with only top corners rounded
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.65, // Show ~top 65% (tweak as you like)
              child: Image.asset(
                img,
                width: 300,
                height: 170, // Use more height so we can "reveal" only the top half
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Info row below image
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Pet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        SizedBox(height: 3),
                        Text(age, style: TextStyle(fontSize: 15)),
                        Text(gender, style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                  // Right: Distance & time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(distance, style: TextStyle(fontSize: 15)),
                      SizedBox(height: 6),
                      Text(time, style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
