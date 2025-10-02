import 'package:flutter/material.dart';
import 'package:pawpal/providers/favourite_provider.dart';
import 'package:provider/provider.dart';


class FavouritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = context.watch<FavouritesProvider>().items;

    return Scaffold(
      backgroundColor: Color(0xFFE8E1F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26,
          ),
        ),
        actions: [
          SizedBox(width: 50),
        ],
        toolbarHeight: 86,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${items.length} Items",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 14),
            if (items.isEmpty)
              Center(child: Text("No favourites yet!")),
            ...items.map((item) => _FavouriteListItem(
              image: item.image,
              title: item.title,
              desc: item.desc,
              price: item.price,
              onRemove: () {
                context.read<FavouritesProvider>().removeFavourite(item);
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _FavouriteListItem extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  final String price;
  final VoidCallback onRemove;

  const _FavouriteListItem({
    required this.image,
    required this.title,
    required this.desc,
    required this.price,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.5,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '\$$price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {}, // Add to cart logic here!
                icon: Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.white),
                label: Text(
                  'Cart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B8BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red, size: 28),
              onPressed: onRemove,
            ),
          ],
        ),
        SizedBox(height: 13),
        Divider(height: 0, thickness: 1.2, color: Colors.grey[300]),
      ],
    );
  }
}
