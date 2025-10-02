import 'package:flutter/material.dart';

class ShopSearchScreen extends StatefulWidget {
  final Function(String)? onQuerySelected; // callback to send query back

  const ShopSearchScreen({Key? key, this.onQuerySelected}) : super(key: key);

  @override
  State<ShopSearchScreen> createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends State<ShopSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _suggestions = [
    'Best cat food',
    'Glasses for cats',
    'Wooden dog food',
    'Best food for rabbits',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (widget.onQuerySelected != null) {
      widget.onQuerySelected!(query);
    }
    Navigator.pop(context, query); // Close and return the query
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 16, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onSubmitted: _onSearch,
                    decoration: InputDecoration(
                      hintText: "Food for rabbit",
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Color(0xFF4B8BFF), width: 1.5),
                      ),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFF4B8BFF), fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, top: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Suggestions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 14),
            ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => _onSearch(s),
                child: Text(s, style: TextStyle(fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
