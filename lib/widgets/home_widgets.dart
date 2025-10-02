import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  const NavItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 40, height: 40,
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}


class PetAdoptCard extends StatefulWidget {
  final String img, name, age, gender;
  final bool isFavorite;
  const PetAdoptCard({
    required this.img,
    required this.name,
    required this.age,
    required this.gender,
    this.isFavorite = false,
  });

  @override
  State<PetAdoptCard> createState() => _PetAdoptCardState();
}

class _PetAdoptCardState extends State<PetAdoptCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // or 108
      margin: EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              widget.img,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(widget.age, style: TextStyle(fontSize: 12)),
          Text(widget.gender,
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}