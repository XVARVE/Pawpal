import 'package:flutter/material.dart';
import 'package:pawpal/screens/adoption/adoption_map_screen.dart';
import 'package:pawpal/screens/adoption/adoption_success_screen.dart';

class AdoptionScheduleScreen extends StatefulWidget {
  final String petImg;
  final String petName;
  final String petBreed;

  const AdoptionScheduleScreen({
    Key? key,
    required this.petImg,
    required this.petName,
    required this.petBreed,
  }) : super(key: key);

  @override
  State<AdoptionScheduleScreen> createState() => _AdoptionScheduleScreenState();
}

class _AdoptionScheduleScreenState extends State<AdoptionScheduleScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  DateTime? _pickedDate;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String get _dateText {
    if (_pickedDate == null) return "17 August 2022";
    return "${_pickedDate!.day} ${_monthString(_pickedDate!.month)} ${_pickedDate!.year}";
  }

  String _monthString(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month];
  }

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF4B8BFF),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Adopt Pet",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
            children: [
              // Information Pet
              SizedBox(height: 12),
              Text("Information Pet",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        widget.petImg,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.petName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 3),
                        Text(widget.petBreed,
                            style: TextStyle(
                                color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22),
              Divider(thickness: 1, height: 1),
              SizedBox(height: 15),
              Text("Create Schedule",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, width: 1.2),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          child: Text(
                            _dateText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22),
              Divider(thickness: 1, height: 1),
              SizedBox(height: 16),
              Text("Adopter Information",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black)),
              SizedBox(height: 14),
              Text("Name", style: TextStyle(fontSize: 15)),
              SizedBox(height: 4),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  hintText: "Input your name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                    BorderSide(color: Color(0xFF4B8BFF), width: 1.4),
                  ),
                ),
              ),
              SizedBox(height: 14),
              Text("Phone", style: TextStyle(fontSize: 15)),
              SizedBox(height: 4),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Input your phone number",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                    BorderSide(color: Color(0xFF4B8BFF), width: 1.4),
                  ),
                ),
              ),
              SizedBox(height: 14),
              Text("Address", style: TextStyle(fontSize: 15)),
              SizedBox(height: 4),
              TextField(
                controller: _address,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Input your address",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                    BorderSide(color: Color(0xFF4B8BFF), width: 1.4),
                  ),
                ),
              ),
            ],
          ),
          // Bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdoptionSuccessScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B8BFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Send Application",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
