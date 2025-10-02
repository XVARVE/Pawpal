import 'package:flutter/material.dart';
import 'package:pawpal/drawers/shop_filter_drawer.dart';
import 'package:pawpal/screens/shop/favourites_screen.dart';
import 'shop_pet.dart';
import 'shop_product.dart';

class ShopScreen extends StatefulWidget {
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedTab = 1;
  PetFilter? _activeFilters;// Default to PET tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set full background to pure white
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white, // solid white for AppBar too
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black), // Heart outline
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavouritesScreen()), // <-- your screen
              );
            },
            tooltip: 'Favourites',
          ),
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
            onPressed: () async {
              final result = await showGeneralDialog<PetFilter>(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Filter",
                barrierColor: Colors.black.withOpacity(0.12),
                transitionDuration: Duration(milliseconds: 250),
                pageBuilder: (context, anim1, anim2) {
                  return Align(
                    alignment: Alignment.centerRight, // Draw on right
                    child: FractionallySizedBox(
                      widthFactor: 0.40,
                      child: ShopFilterDrawer(
                        initialFilter: _activeFilters,
                        onApply: (filterResult) {
                          Navigator.pop(context, filterResult);
                        },
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(1, 0), // From right
                      end: Offset(0, 0),
                    ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
                    child: child,
                  );
                },
              );
              if (result != null) {
                setState(() {
                  _activeFilters = result;
                });
              }
            },

            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2, right: 28, bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Find the best product or pet',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),

          // Custom Tab Bar
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 8, top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 0 ? Colors.black : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "PRODUCT",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _selectedTab == 0 ? Colors.black : Colors.black54,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 8, top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 1 ? Colors.black : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "PET",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _selectedTab == 1 ? Colors.black : Colors.black54,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.black12, thickness: 1),

          // Animated content
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedTab == 1
                  ? ShopPetScreen(key: ValueKey('pet'), filters: _activeFilters)
                  : ShopProductScreen(key: ValueKey('product')),
            ),
          ),
        ],
      ),
    );
  }
}