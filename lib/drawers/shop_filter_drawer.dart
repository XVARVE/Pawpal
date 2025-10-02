import 'package:flutter/material.dart';

// Data model for selected filters (simple for now)
class PetFilter {
  final String? sort;
  final String? typePet;
  final String? species;
  final String? age;
  final String? size;
  final String? location;

  PetFilter({
    this.sort,
    this.typePet,
    this.species,
    this.age,
    this.size,
    this.location,
  });

  PetFilter copyWith({
    String? sort,
    String? typePet,
    String? species,
    String? age,
    String? size,
    String? location,
  }) {
    return PetFilter(
      sort: sort ?? this.sort,
      typePet: typePet ?? this.typePet,
      species: species ?? this.species,
      age: age ?? this.age,
      size: size ?? this.size,
      location: location ?? this.location,
    );
  }
}

class ShopFilterDrawer extends StatefulWidget {
  final PetFilter? initialFilter;
  final void Function(PetFilter) onApply;

  const ShopFilterDrawer({
    Key? key,
    this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<ShopFilterDrawer> createState() => _ShopFilterDrawerState();
}

class _ShopFilterDrawerState extends State<ShopFilterDrawer> {
  late PetFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter ?? PetFilter();
  }

  void _clearAll() {
    setState(() {
      _filter = PetFilter();
    });
  }

  // These lists represent possible filter options. You can update as needed!
  final sortOptions = ['Best Match', 'Price Low-High', 'Price High-Low'];
  final typePetOptions = ['Dog', 'Cat', 'Rabbit', 'Turtle', 'Bird'];
  final speciesOptions = ['All', 'Persian', 'Labrador', 'Angora', 'Cockatoo'];
  final ageOptions = ['0-1', '1-3', '3-6', '6+'];
  final sizeOptions = ['Small', 'Medium', 'Large', '4-7 Kg'];
  final locationOptions = ['California', 'New York', 'Texas', 'Florida'];

  Widget _buildTile({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            Row(
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                SizedBox(width: 7),
                Icon(Icons.chevron_right, size: 20, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickOption(String title, List<String> options, String? selected, void Function(String) onSelected) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: TextStyle(
                fontWeight: opt == selected ? FontWeight.bold : FontWeight.normal,
                color: opt == selected ? Color(0xFF4B8BFF) : Colors.black,
              )),
              trailing: opt == selected ? Icon(Icons.check, color: Color(0xFF4B8BFF)) : null,
              onTap: () => Navigator.pop(context, opt),
            )),
          ],
        );
      },
    );
    if (result != null) {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text('Filters', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text('Clear All', style: TextStyle(color: Color(0xFF4B8BFF), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Divider(height: 0, thickness: 1.1,),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildTile(
                  label: 'Sort',
                  value: _filter.sort ?? 'Best Match',
                  onTap: () => _pickOption('Sort', sortOptions, _filter.sort, (v) => setState(() => _filter = _filter.copyWith(sort: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
                _buildTile(
                  label: 'Type Pet',
                  value: _filter.typePet ?? 'Dog',
                  onTap: () => _pickOption('Type Pet', typePetOptions, _filter.typePet, (v) => setState(() => _filter = _filter.copyWith(typePet: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
                _buildTile(
                  label: 'Species',
                  value: _filter.species ?? 'All',
                  onTap: () => _pickOption('Species', speciesOptions, _filter.species, (v) => setState(() => _filter = _filter.copyWith(species: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
                _buildTile(
                  label: 'Age',
                  value: _filter.age ?? '0-1',
                  onTap: () => _pickOption('Age', ageOptions, _filter.age, (v) => setState(() => _filter = _filter.copyWith(age: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
                _buildTile(
                  label: 'Size (Weight)',
                  value: _filter.size ?? '4-7 Kg',
                  onTap: () => _pickOption('Size', sizeOptions, _filter.size, (v) => setState(() => _filter = _filter.copyWith(size: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
                _buildTile(
                  label: 'Location',
                  value: _filter.location ?? 'California',
                  onTap: () => _pickOption('Location', locationOptions, _filter.location, (v) => setState(() => _filter = _filter.copyWith(location: v))),
                ),
                Divider(height: 0, thickness: 1, color: Color(0xFFEDEDED)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filter);
                  Navigator.pop(context);
                },
                child: Text('Apply Filter', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B8BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
